%%% -*- coding: utf-8 -*-
%%% ----------------------------------------------------------------------------
%%% Copyright (c) 2009, Erlang Training and Consulting Ltd.
%%% All rights reserved.
%%%
%%% Redistribution and use in source and binary forms, with or without
%%% modification, are permitted provided that the following conditions are met:
%%%    * Redistributions of source code must retain the above copyright
%%%      notice, this list of conditions and the following disclaimer.
%%%    * Redistributions in binary form must reproduce the above copyright
%%%      notice, this list of conditions and the following disclaimer in the
%%%      documentation and/or other materials provided with the distribution.
%%%    * Neither the name of Erlang Training and Consulting Ltd. nor the
%%%      names of its contributors may be used to endorse or promote products
%%%      derived from this software without specific prior written permission.
%%%
%%% THIS SOFTWARE IS PROVIDED BY Erlang Training and Consulting Ltd. ''AS IS''
%%% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%%% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
%%% ARE DISCLAIMED. IN NO EVENT SHALL Erlang Training and Consulting Ltd. BE
%%% LIABLE SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
%%% BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
%%% WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
%%% OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
%%% ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%%% ----------------------------------------------------------------------------

%%------------------------------------------------------------------------------
%%% @author Oscar Hellström <oscar@hellstrom.st>
%%% @author Filipe David Manana <fdmanana@apache.org>
%%% @doc Connection manager for the HTTP client.
%%% This gen_server is responsible for keeping track of persistent
%%% connections to HTTP servers. The only interesting API is
%%% `connection_count/0' and `connection_count/1'.
%%% The gen_server is supposed to be started by a supervisor, which is
%%% normally {@link lhttpc_sup}.
%%% @end
%%------------------------------------------------------------------------------
-module(lhttpc_manager).

%% Exported functions
-export([start_link/0, start_link/1,
         client_count/1,
         connection_count/1, connection_count/2,
         update_connection_timeout/2,
         dump_settings/1,
         list_pools/0,
         set_max_pool_size/2,
         ensure_call/6,
         client_done/5
        ]).

-ignore_xref(
        [start_link/0, start_link/1,
         client_count/1,
         connection_count/1, connection_count/2,
         update_connection_timeout/2,
         dump_settings/1,
         list_pools/0,
         set_max_pool_size/2,
         ensure_call/6,
         client_done/5
        ]).

%% Callbacks
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         code_change/3,
         terminate/2
        ]).

-behaviour(gen_server).

-record(state, {
        destinations = dict:new() :: destinations(),
        sockets = dict:new() :: sockets(),
        clients = dict:new() :: clients(), % Pid => {Dest, MonRef}
        queues = dict:new() :: queues(),   % Dest => queue of Froms
        max_pool_size = 50 :: non_neg_integer(),
        timeout = 300000 :: non_neg_integer()
    }).
-type state() :: #state{}.
-type destinations() :: dict:dict(lhttpc:destination(), [lhttpc:socket()]).
-type sockets() :: dict:dict(lhttpc:socket(), {lhttpc:destination(), reference()}).
-type clients() :: dict:dict(pid(), {lhttpc:destination(), reference()}).
-type queues() :: dict:dict(lhttpc:destination(), queue:queue(gen_server:from())).

%%==============================================================================
%% Exported functions
%%==============================================================================

%%------------------------------------------------------------------------------
%% @doc Returns the current settings in state for the
%% specified lhttpc pool (manager).
%% @end
%%------------------------------------------------------------------------------
-spec dump_settings(lhttpc:pool_id()) -> list().
dump_settings(PidOrName) ->
    gen_server:call(PidOrName, dump_settings).

%%------------------------------------------------------------------------------
%% @doc Sets the maximum pool size for the specified pool.
%% @end
%%------------------------------------------------------------------------------
-spec set_max_pool_size(lhttpc:pool_id(), non_neg_integer()) -> ok.
set_max_pool_size(PidOrName, Size) when is_integer(Size), Size > 0 ->
    gen_server:cast(PidOrName, {set_max_pool_size, Size}).

%%------------------------------------------------------------------------------
%% @doc Lists all the pools already started.
%% @end
%%------------------------------------------------------------------------------
-spec list_pools() -> term().
list_pools() ->
    Children = supervisor:which_children(lhttpc_sup),
    lists:foldl(fun(In, Acc) ->
                        case In of
                            {N, P, _, [lhttpc_manager]} ->
                                [{N, dump_settings(P)} | Acc];
                            _ ->
                                Acc
                        end
                end, [], Children).

%%------------------------------------------------------------------------------
%% @doc Returns the total number of active clients maintained by the
%% specified lhttpc pool (manager).
%% @end
%%------------------------------------------------------------------------------
-spec client_count(lhttpc:pool_id()) -> non_neg_integer().
client_count(PidOrName) ->
    gen_server:call(PidOrName, client_count).

%%------------------------------------------------------------------------------
%% @doc Returns the total number of active connections maintained by the
%% specified lhttpc pool (manager).
%% @end
%%------------------------------------------------------------------------------
-spec connection_count(lhttpc:pool_id()) -> non_neg_integer().
connection_count(PidOrName) ->
    gen_server:call(PidOrName, connection_count).

%%------------------------------------------------------------------------------
%% @doc Returns the number of active connections to the specific
%% `Destination' maintained by the httpc manager.
%% @end
%%------------------------------------------------------------------------------
-spec connection_count(lhttpc:pool_id(), lhttpc:destination()) -> non_neg_integer().
connection_count(PidOrName, {Host, Port, Ssl}) ->
    Destination = {string:to_lower(Host), Port, Ssl},
    gen_server:call(PidOrName, {connection_count, Destination}).

%%------------------------------------------------------------------------------
%% @doc Updates the timeout for persistent connections.
%% This will only affect future sockets handed to the manager. The sockets
%% already managed will keep their timers.
%% @end
%%------------------------------------------------------------------------------
-spec update_connection_timeout(lhttpc:pool_id(), non_neg_integer()) -> ok.
update_connection_timeout(PidOrName, Milliseconds) ->
    gen_server:cast(PidOrName, {update_timeout, Milliseconds}).

%%------------------------------------------------------------------------------
%% @doc Starts and link to the gen server.
%% This is normally called by a supervisor.
%% @end
%%------------------------------------------------------------------------------
-spec start_link() -> {ok, pid()} | {error, already_started}.
start_link() ->
    start_link([]).


%%------------------------------------------------------------------------------
%% @doc Starts and link to the gen server (with options).
%% This is normally called by a supervisor.
%% @end
%%------------------------------------------------------------------------------
-spec start_link([{atom(), non_neg_integer()}]) ->
    {ok, pid()} | {error, already_started}.
start_link(Options0) ->
    Options = maybe_apply_defaults([connection_timeout, pool_size], Options0),
    case proplists:get_value(name, Options) of
        undefined ->
            gen_server:start_link(?MODULE, Options, []);
        Name ->
            gen_server:start_link({local, Name}, ?MODULE, Options, [])
    end.

%%------------------------------------------------------------------------------
%% @doc If call contains pool_ensure option, dynamically create the pool with
%% configured parameters. Checks the pool for a socket connected to the
%% destination and returns it if it exists, 'undefined' otherwise.
%% @end
%%------------------------------------------------------------------------------
-spec ensure_call(lhttpc:pool_id(), pid(), lhttpc:host(), lhttpc:port_num(), boolean(),
                  lhttpc:options()) ->
                        lhttpc:socket() | 'undefined'.
ensure_call(Pool, Pid, Host, Port, Ssl, Options) ->
    SocketRequest = {socket, Pid, Host, Port, Ssl},
    try gen_server:call(Pool, SocketRequest, infinity) of
        {ok, S} ->
            %% Re-using HTTP/1.1 connections
            S;
        no_socket ->
            %% Opening a new HTTP/1.1 connection
            undefined
    catch
        exit:{noproc, Reason} ->
            case proplists:get_value(pool_ensure, Options, false) of
                true ->
                    {ok, DefaultTimeout} = application:get_env(
                                             lhttpc,
                                             connection_timeout),
                    ConnTimeout = proplists:get_value(pool_connection_timeout,
                                                      Options,
                                                      DefaultTimeout),
                    {ok, DefaultMaxPool} = application:get_env(
                                             lhttpc,
                                             pool_size),
                    PoolMaxSize = proplists:get_value(pool_max_size,
                                                      Options,
                                                      DefaultMaxPool),
                    case lhttpc:add_pool(Pool, ConnTimeout, PoolMaxSize) of
                        {ok, _Pid} ->
                            ensure_call(Pool, Pid, Host, Port, Ssl, Options);
                        {error, already_exists} ->
                            % race condition
                            Options2 = proplists:delete(pool_ensure, Options),
                            Options3 = [{pool_ensure, false} | Options2],
                            ensure_call(Pool, Pid, Host, Port, Ssl, Options3);
                        _ ->
                            %% Failed to create pool, exit as expected
                            exit({noproc, Reason})
                    end;
                false ->
                    %% No dynamic pool creation, exit as expected
                    exit({noproc, Reason})
            end
    end.

%%------------------------------------------------------------------------------
%% @doc A client has finished one request and returns the socket to the pool,
%% which can be new or not.
%% @end
%%------------------------------------------------------------------------------
-spec client_done(pid(), lhttpc:host(), lhttpc:port_num(), boolean(), lhttpc:socket()) -> ok.
client_done(Pool, Host, Port, Ssl, Socket) ->
    case lhttpc_sock:controlling_process(Socket, Pool, Ssl) of
        {ok, PoolPid} ->
            DoneMsg = {done, Host, Port, Ssl, Socket},
            try
                ok = gen_server:call(PoolPid, DoneMsg, infinity)
            catch
                exit:{noproc, _} ->
                    _ = safe_close(Socket, Ssl),
                    ok;
                exit:{killed, _} ->
                    _ = safe_close(Socket, Ssl),
                    ok
            end;
        _ ->
            ok
    end.

%%==============================================================================
%% Callbacks
%%==============================================================================

%%------------------------------------------------------------------------------
%% @hidden
%%------------------------------------------------------------------------------
-spec init([any()]) -> {ok, state()}.
init(Options) ->
    process_flag(priority, high),
    Timeout = proplists:get_value(connection_timeout, Options),
    Size = proplists:get_value(pool_size, Options),
    {ok, #state{timeout = Timeout, max_pool_size = Size}}.

%%------------------------------------------------------------------------------
%% @hidden
%%------------------------------------------------------------------------------
-spec handle_call(any(), any(), state()) ->
    {reply, any(), state()}.
handle_call({socket, Pid, Host, Port, Ssl}, {Pid, _Ref} = From, State) ->
    #state{
        max_pool_size = MaxSize,
        clients = Clients,
        queues = Queues
    } = State,
    Dest = {Host, Port, Ssl},
    {Reply0, State2} = find_socket(Dest, Pid, State),
    case Reply0 of
        {ok, _Socket} ->
            State3 = monitor_client(Dest, From, State2),
            {reply, Reply0, State3};
        no_socket ->
            case dict:size(Clients) >= MaxSize of
                true ->
                    Queues2 = add_to_queue(Dest, From, Queues),
                    {noreply, State2#state{queues = Queues2}};
                false ->
                    {reply, no_socket, monitor_client(Dest, From, State2)}
            end
    end;
handle_call(dump_settings, _, State) ->
    {reply, [{max_pool_size, State#state.max_pool_size}, {timeout, State#state.timeout}],
     State};
handle_call(client_count, _, State) ->
    {reply, dict:size(State#state.clients), State};
handle_call(connection_count, _, State) ->
    {reply, dict:size(State#state.sockets), State};
handle_call({connection_count, Destination}, _, State) ->
    Count = case dict:find(Destination, State#state.destinations) of
        {ok, Sockets} -> length(Sockets);
        error         -> 0
    end,
    {reply, Count, State};
handle_call({done, Host, Port, Ssl, Socket}, {Pid, _} = From, State) ->
    gen_server:reply(From, ok),
    FinalState =
        try
            Dest = {Host, Port, Ssl},
            {Dest, MonRef} = dict:fetch(Pid, State#state.clients),
            true = erlang:demonitor(MonRef, [flush]),
            Clients2 = dict:erase(Pid, State#state.clients),
            deliver_socket(Socket, Dest, State#state{clients = Clients2})
        catch
            Class:Reason:Stacktrace ->
                CloseStatus = safe_close(Socket, Ssl),
                error_logger:info_msg("lhttpc_manager, unrecognized socket (close_status ~p) "
                                      "is done (error ~p:~p, stacktrace ~p)",
                                      [CloseStatus, Class, Reason, Stacktrace]),
                State
        end,

    {noreply, FinalState};
handle_call(_, _, State) ->
    {reply, {error, unknown_request}, State}.

%%------------------------------------------------------------------------------
%% @hidden
%%------------------------------------------------------------------------------
-spec handle_cast(any(), state()) -> {noreply, state()}.
handle_cast({update_timeout, Milliseconds}, State) ->
    {noreply, State#state{timeout = Milliseconds}};
handle_cast({set_max_pool_size, Size}, State) ->
    {noreply, State#state{max_pool_size = Size}};
handle_cast(_, State) ->
    {noreply, State}.

%%------------------------------------------------------------------------------
%% @hidden
%%------------------------------------------------------------------------------
-spec handle_info(any(), state()) -> {noreply, state()}.
handle_info({tcp_closed, Socket}, State) ->
    {noreply, remove_socket(Socket, State)};
handle_info({ssl_closed, Socket}, State) ->
    {noreply, remove_socket(Socket, State)};
handle_info({timeout, Socket}, State) ->
    {noreply, remove_socket(Socket, State)};
handle_info({tcp_error, Socket, _}, State) ->
    {noreply, remove_socket(Socket, State)};
handle_info({ssl_error, Socket, _}, State) ->
    {noreply, remove_socket(Socket, State)};
handle_info({tcp, Socket, _}, State) ->
    {noreply, remove_socket(Socket, State)}; % got garbage
handle_info({ssl, Socket, _}, State) ->
    {noreply, remove_socket(Socket, State)}; % got garbage
handle_info({'DOWN', MonRef, process, Pid, _Reason}, State) ->
    {Dest, MonRef} = dict:fetch(Pid, State#state.clients),
    Clients2 = dict:erase(Pid, State#state.clients),
    case queue_out(Dest, State#state.queues) of
        empty ->
            {noreply, State#state{clients = Clients2}};
        {ok, From, Queues2} ->
            gen_server:reply(From, no_socket),
            State2 = State#state{queues = Queues2, clients = Clients2},
            {noreply, monitor_client(Dest, From, State2)}
    end;
handle_info(_, State) ->
    {noreply, State}.

%%------------------------------------------------------------------------------
%% @hidden
%%------------------------------------------------------------------------------
-spec terminate(any(), state()) -> ok.
terminate(_, State) ->
    close_sockets(State#state.sockets).

%%------------------------------------------------------------------------------
%% @hidden
%%------------------------------------------------------------------------------
-spec code_change(any(), state(), any()) -> {'ok', state()}.
code_change(_, State, _) ->
    {ok, State}.

%%==============================================================================
%% Internal functions
%%==============================================================================

%------------------------------------------------------------------------------
%% @private
%%------------------------------------------------------------------------------
-spec find_socket(lhttpc:destination(), pid(), state()) ->
    {{'ok', lhttpc:socket()} | 'no_socket', state()}.
find_socket({_, _, Ssl} = Dest, Pid, State) ->
    Dests = State#state.destinations,
    case dict:find(Dest, Dests) of
        {ok, [Socket | Sockets]} ->
            lhttpc_sock:setopts(Socket, [{active, false}], Ssl),
            case lhttpc_sock:controlling_process(Socket, Pid, Ssl) of
                {ok, Pid} ->
                    {_, Timer} = dict:fetch(Socket, State#state.sockets),
                    cancel_timer(Timer, Socket),
                    NewState = State#state{
                        destinations = update_dest(Dest, Sockets, Dests),
                        sockets = dict:erase(Socket, State#state.sockets)
                    },
                    {{ok, Socket}, NewState};
                {error, badarg} -> % Pid has timed out, reuse for someone else
                    lhttpc_sock:setopts(Socket, [{active, once}], Ssl),
                    {no_socket, State};
                _ -> % something wrong with the socket; remove it, try again
                    find_socket(Dest, Pid, remove_socket(Socket, State))
            end;
        error ->
            {no_socket, State}
    end.

%------------------------------------------------------------------------------
%% @private
%%------------------------------------------------------------------------------
-spec remove_socket(lhttpc:socket(), state()) -> state().
remove_socket(Socket, State) ->
    Dests = State#state.destinations,
    case dict:find(Socket, State#state.sockets) of
        {ok, {{_, _, Ssl} = Dest, Timer}} ->
            cancel_timer(Timer, Socket),
            lhttpc_sock:close(Socket, Ssl),
            Sockets = lists:delete(Socket, dict:fetch(Dest, Dests)),
            State#state{
                destinations = update_dest(Dest, Sockets, Dests),
                sockets = dict:erase(Socket, State#state.sockets)
            };
        error ->
            State
    end.

%------------------------------------------------------------------------------
%% @private
%%------------------------------------------------------------------------------
-spec store_socket(lhttpc:destination(), lhttpc:socket(), state()) -> state().
store_socket({_, _, Ssl} = Dest, Socket, State) ->
    Timeout = State#state.timeout,
    Timer = erlang:send_after(Timeout, self(), {timeout, Socket}),
    % the socket might be closed from the other side
    lhttpc_sock:setopts(Socket, [{active, once}], Ssl),
    Dests = State#state.destinations,
    Sockets = case dict:find(Dest, Dests) of
        {ok, S} -> [Socket | S];
        error   -> [Socket]
    end,
    State#state{
        destinations = dict:store(Dest, Sockets, Dests),
        sockets = dict:store(Socket, {Dest, Timer}, State#state.sockets)
    }.

%------------------------------------------------------------------------------
%% @private
%%------------------------------------------------------------------------------
-spec update_dest(lhttpc:destination(), [lhttpc:socket()], destinations()) -> destinations().
update_dest(Destination, [], Destinations) ->
    dict:erase(Destination, Destinations);
update_dest(Destination, Sockets, Destinations) ->
    dict:store(Destination, Sockets, Destinations).

%------------------------------------------------------------------------------
%% @private
%%------------------------------------------------------------------------------
-spec close_sockets(sockets()) -> ok.
close_sockets(Sockets) ->
    lists:foreach(fun({Socket, {{_, _, Ssl}, Timer}}) ->
                lhttpc_sock:close(Socket, Ssl),
                erlang:cancel_timer(Timer)
        end, dict:to_list(Sockets)).

%------------------------------------------------------------------------------
%% @private
%%------------------------------------------------------------------------------
-spec cancel_timer(reference(), lhttpc:socket()) -> ok.
cancel_timer(Timer, Socket) ->
    case erlang:cancel_timer(Timer) of
        false ->
            receive
                {timeout, Socket} -> ok
            after
                0 -> ok
            end;
        _     -> ok
    end.

%------------------------------------------------------------------------------
%% @private
%%------------------------------------------------------------------------------
-spec add_to_queue(lhttpc:destination(), gen_server:from(), queues()) -> queues().
add_to_queue({_Host, _Port, _Ssl} = Dest, From, Queues) ->
    case dict:find(Dest, Queues) of
        error ->
            dict:store(Dest, queue:in(From, queue:new()), Queues);
        {ok, Q} ->
            dict:store(Dest, queue:in(From, Q), Queues)
    end.

%------------------------------------------------------------------------------
%% @private
%%------------------------------------------------------------------------------
-spec queue_out(lhttpc:destination(), queues()) ->
    'empty' | {'ok', gen_server:from(), queues()}.
queue_out({_Host, _Port, _Ssl} = Dest, Queues) ->
    case dict:find(Dest, Queues) of
        error ->
            empty;
        {ok, Q} ->
            {{value, From}, Q2} = queue:out(Q),
            Queues2 = case queue:is_empty(Q2) of
                true ->
                    dict:erase(Dest, Queues);
                false ->
                    dict:store(Dest, Q2, Queues)
            end,
            {ok, From, Queues2}
    end.

%------------------------------------------------------------------------------
%% @private
%%------------------------------------------------------------------------------
-spec deliver_socket(lhttpc:socket(), lhttpc:destination(), state()) -> state().
deliver_socket(Socket, {_, _, Ssl} = Dest, State) ->
    case queue_out(Dest, State#state.queues) of
        empty ->
            store_socket(Dest, Socket, State);
        {ok, {PidWaiter, _} = FromWaiter, Queues2} ->
            lhttpc_sock:setopts(Socket, [{active, false}], Ssl),
            case lhttpc_sock:controlling_process(Socket, PidWaiter, Ssl) of
                {ok, PidWaiter} ->
                    gen_server:reply(FromWaiter, {ok, Socket}),
                    monitor_client(Dest, FromWaiter, State#state{queues = Queues2});
                {error, badarg} -> % Pid died, reuse for someone else
                    lhttpc_sock:setopts(Socket, [{active, once}], Ssl),
                    deliver_socket(Socket, Dest, State#state{queues = Queues2});
                _ -> % Something wrong with the socket; just remove it
                    _ = safe_close(Socket, Ssl),
                    State
            end
    end.

%------------------------------------------------------------------------------
%% @private
%%------------------------------------------------------------------------------
-spec monitor_client(lhttpc:destination(), gen_server:from(), state()) -> state().
monitor_client(Dest, {Pid, _} = _From, State) ->
    MonRef = erlang:monitor(process, Pid),
    Clients2 = dict:store(Pid, {Dest, MonRef}, State#state.clients),
    State#state{clients = Clients2}.

%------------------------------------------------------------------------------
%% @private
%%------------------------------------------------------------------------------
-spec maybe_apply_defaults([atom()], [{atom(), term()}]) -> [{atom(), term()}].
maybe_apply_defaults([], Options) ->
    Options;
maybe_apply_defaults([OptName | Rest], Options) ->
    case proplists:is_defined(OptName, Options) of
        true ->
            maybe_apply_defaults(Rest, Options);
        false ->
            {ok, Default} = application:get_env(lhttpc, OptName),
            maybe_apply_defaults(Rest, [{OptName, Default} | Options])
    end.

%------------------------------------------------------------------------------
%% @private
%%------------------------------------------------------------------------------
-spec safe_close(lhttpc:socket(), boolean()) -> ok | {error, term()}.
safe_close(Socket, Ssl) ->
    try
        lhttpc_sock:close(Socket, Ssl)
    catch
        Class:Reason -> {error, {Class, Reason}}
    end.
