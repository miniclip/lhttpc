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

%%% @author Oscar Hellström <oscar@hellstrom.st>
-module(lhttpc_test_SUITE).
-compile(export_all).

-export([test_no/2]).

-include_lib("eunit/include/eunit.hrl").

-define(PROJECT_ROOT, "../../../.."). % different from eunit's

-define(DEFAULT_STRING, "Great success!").
-define(LONG_BODY_PART,
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
        "This is a relatively long body, that we send to the client... "
    ).

test_no(N, Tests) ->
    setelement(2, Tests,
        setelement(4, element(2, Tests),
            lists:nth(N, element(4, element(2, Tests))))).

%% ------------------------------------------------------------------
%% Enumeration
%% ------------------------------------------------------------------

all() ->
    [{group, GroupName} || {GroupName, _Options, _TestCases} <- groups()].

groups() ->
    [{tcp_tests, [sequence], tcp_tests()},
     {ssl_tests, [sequence], ssl_tests()}
    ].

%% ------------------------------------------------------------------
%% Initialization
%% ------------------------------------------------------------------

init_per_group(_GroupName, Config) ->
    {ok, _} = application:ensure_all_started(lhttpc),
    Config.

end_per_group(_TestCase, Config) ->
    ok = application:stop(lhttpc),
    Config.

%% ------------------------------------------------------------------
%% Group Definition
%% ------------------------------------------------------------------

tcp_tests() ->
    [simple_get,
     simple_get_ipv6,
     empty_get,
     basic_auth,
     missing_basic_auth,
     wrong_basic_auth,
     get_with_mandatory_hdrs,
     get_with_mandatory_hdrs_by_atoms,
     get_with_mandatory_hdrs_by_binaries,
     get_with_connect_options,
     no_content_length,
     no_content_length_1_0,
     get_not_modified,
     simple_head,
     simple_head_atom,
     delete_no_content,
     delete_content,
     options_content,
     options_no_content,
     server_connection_close,
     client_connection_close,
     pre_1_1_server_connection,
     pre_1_1_server_keep_alive,
     simple_put,
     post,
     post_100_continue,
     persistent_connection,
     request_timeout,
     connection_timeout,
     suspended_manager,
     chunked_encoding,
     partial_upload_identity,
     partial_upload_identity_iolist,
     partial_upload_chunked,
     partial_upload_chunked_no_trailer,
     partial_download_illegal_option,
     partial_download_identity,
     partial_download_infinity_window,
     partial_download_no_content_length,
     partial_download_no_content,
     limited_partial_download_identity,
     partial_download_chunked,
     partial_download_chunked_infinite_part,
     partial_download_smallish_chunks,
     partial_download_slow_chunks,
     close_connection,
     message_queue,
     trailing_space_header,
     connection_count % just check that it's 0 (last)
    ].

ssl_tests() ->
    [ssl_get,
     ssl_get_ipv6,
     ssl_post,
     ssl_chunked,
     connection_count % just check that it's 0 (last)
    ].

%% ------------------------------------------------------------------
%% Test Cases Definition
%% ------------------------------------------------------------------

message_queue(_Config) ->
    receive X -> erlang:error({unexpected_message, X}) after 0 -> ok end.

simple_get(_Config) ->
    simple(get),
    simple("GET").

-ifdef(SKIP_IPV6_TEST_CASES).
simple_get_ipv6(_Config) ->
    {skip, "IPv6 support not considered"}.
-else.
simple_get_ipv6(_Config) ->
    simple(get, inet6),
    simple("GET", inet6).
-endif.

empty_get(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [fun empty_body/5]),
    URL = url(Port, "/empty"),
    {ok, Response} = lhttpc:request(URL, "GET", [], 1000),
    ?assertEqual({200, "OK"}, status(Response)),
    ?assertEqual(<<>>, body(Response)).

basic_auth(_Config) ->
    User = "foo",
    Passwd = "bar",
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [basic_auth_responder(User, Passwd)]),
    URL = url(Port, "/empty", User, Passwd),
    {ok, Response} = lhttpc:request(URL, "GET", [], 1000),
    ?assertEqual({200, "OK"}, status(Response)),
    ?assertEqual(<<"OK">>, body(Response)).

missing_basic_auth(_Config) ->
    User = "foo",
    Passwd = "bar",
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [basic_auth_responder(User, Passwd)]),
    URL = url(Port, "/empty"),
    {ok, Response} = lhttpc:request(URL, "GET", [], 1000),
    ?assertEqual({401, "Unauthorized"}, status(Response)),
    ?assertEqual(<<"missing_auth">>, body(Response)).

wrong_basic_auth(_Config) ->
    User = "foo",
    Passwd = "bar",
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [basic_auth_responder(User, Passwd)]),
    URL = url(Port, "/empty", User, "wrong_password"),
    {ok, Response} = lhttpc:request(URL, "GET", [], 1000),
    ?assertEqual({401, "Unauthorized"}, status(Response)),
    ?assertEqual(<<"wrong_auth">>, body(Response)).

get_with_mandatory_hdrs(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [fun simple_response/5]),
    URL = url(Port, "/host"),
    Body = <<?DEFAULT_STRING>>,
    Hdrs = [
        {"content-length", integer_to_list(size(Body))},
        {"host", "localhost"}
    ],
    {ok, Response} = lhttpc:request(URL, "POST", Hdrs, Body, 1000),
    ?assertEqual({200, "OK"}, status(Response)),
    ?assertEqual(<<?DEFAULT_STRING>>, body(Response)).

get_with_mandatory_hdrs_by_atoms(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [fun simple_response/5]),
    URL = url(Port, "/host"),
    Body = <<?DEFAULT_STRING>>,
    Hdrs = [
        {'Content-Length', integer_to_list(size(Body))},
        {'Host', "localhost"}
    ],
    {ok, Response} = lhttpc:request(URL, "POST", Hdrs, Body, 1000),
    ?assertEqual({200, "OK"}, status(Response)),
    ?assertEqual(<<?DEFAULT_STRING>>, body(Response)).

get_with_mandatory_hdrs_by_binaries(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [fun simple_response/5]),
    URL = url(Port, "/host"),
    Body = <<?DEFAULT_STRING>>,
    Hdrs = [
        {<<"Content-Length">>, integer_to_list(size(Body))},
        {<<"Host">>, "localhost"}
    ],
    {ok, Response} = lhttpc:request(URL, "POST", Hdrs, Body, 1000),
    ?assertEqual({200, "OK"}, status(Response)),
    ?assertEqual(<<?DEFAULT_STRING>>, body(Response)).

get_with_connect_options(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [fun empty_body/5]),
    URL = url(Port, "/empty"),
    Options = [{connect_options, [{ip, {127, 0, 0, 1}}, {port, 0}]}],
    {ok, Response} = lhttpc:request(URL, "GET", [], [], 1000, Options),
    ?assertEqual({200, "OK"}, status(Response)),
    ?assertEqual(<<>>, body(Response)).

no_content_length(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [fun no_content_length/5]),
    URL = url(Port, "/no_cl"),
    {ok, Response} = lhttpc:request(URL, "GET", [], 1000),
    ?assertEqual({200, "OK"}, status(Response)),
    ?assertEqual(<<?DEFAULT_STRING>>, body(Response)).

no_content_length_1_0(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [fun no_content_length_1_0/5]),
    URL = url(Port, "/no_cl"),
    {ok, Response} = lhttpc:request(URL, "GET", [], 1000),
    ?assertEqual({200, "OK"}, status(Response)),
    ?assertEqual(<<?DEFAULT_STRING>>, body(Response)).

-ifdef(SKIP_BROKEN_TEST_CASES).
trailing_space_header(_Config) ->
    {skip, "Broken test case"}.
-else.
%% Check the header value is trimming spaces on header values
%% which can cause crash in lhttpc_client:body_type when Content-Length
%% is converted from list to integer
trailing_space_header(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [fun trailing_space_header/5]),
    URL = url(Port, "/no_cl"),
    {ok, Response} = lhttpc:request(URL, "GET", [], 1000),
    Headers = headers(Response),
    ContentLength = lhttpc_lib:header_value("Content-Length", Headers),
    ?assertEqual("14", ContentLength).
-endif.

get_not_modified(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [fun not_modified_response/5]),
    URL = url(Port, "/not_modified"),
    {ok, Response} = lhttpc:request(URL, "GET", [], [], 1000),
    ?assertEqual({304, "Not Modified"}, status(Response)),
    ?assertEqual(<<>>, body(Response)).

simple_head(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [fun head_response/5]),
    URL = url(Port, "/HEAD"),
    {ok, Response} = lhttpc:request(URL, "HEAD", [], 1000),
    ?assertEqual({200, "OK"}, status(Response)),
    ?assertEqual(<<>>, body(Response)).

simple_head_atom(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [fun head_response/5]),
    URL = url(Port, "/head"),
    {ok, Response} = lhttpc:request(URL, head, [], 1000),
    ?assertEqual({200, "OK"}, status(Response)),
    ?assertEqual(<<>>, body(Response)).

delete_no_content(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [fun no_content_response/5]),
    URL = url(Port, "/delete_no_content"),
    {ok, Response} = lhttpc:request(URL, delete, [], 1000),
    ?assertEqual({204, "OK"}, status(Response)),
    ?assertEqual(<<>>, body(Response)).

delete_content(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [fun simple_response/5]),
    URL = url(Port, "/delete_content"),
    {ok, Response} = lhttpc:request(URL, "DELETE", [], 1000),
    ?assertEqual({200, "OK"}, status(Response)),
    ?assertEqual(<<?DEFAULT_STRING>>, body(Response)).

options_no_content(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [fun head_response/5]),
    URL = url(Port, "/options_no_content"),
    {ok, Response} = lhttpc:request(URL, "OPTIONS", [], 1000),
    ?assertEqual({200, "OK"}, status(Response)),
    ?assertEqual(<<>>, body(Response)).

options_content(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [fun simple_response/5]),
    URL = url(Port, "/options_content"),
    {ok, Response} = lhttpc:request(URL, "OPTIONS", [], 1000),
    ?assertEqual({200, "OK"}, status(Response)),
    ?assertEqual(<<?DEFAULT_STRING>>, body(Response)).

server_connection_close(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [fun respond_and_close/5]),
    URL = url(Port, "/close"),
    Body = pid_to_list(self()),
    {ok, Response} = lhttpc:request(URL, "PUT", [], Body, 1000),
    ?assertEqual({200, "OK"}, status(Response)),
    ?assertEqual(<<?DEFAULT_STRING>>, body(Response)),
    receive closed -> ok end.

client_connection_close(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [fun respond_and_wait/5]),
    URL = url(Port, "/close"),
    Body = pid_to_list(self()),
    Hdrs = [{"Connection", "close"}],
    {ok, _} = lhttpc:request(URL, put, Hdrs, Body, 1000),
    % Wait for the server to see that socket has been closed
    receive closed -> ok end.

pre_1_1_server_connection(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [fun pre_1_1_server/5]),
    URL = url(Port, "/close"),
    Body = pid_to_list(self()),
    {ok, _} = lhttpc:request(URL, put, [], Body, 1000),
    % Wait for the server to see that socket has been closed.
    % The socket should be closed by us since the server responded with a
    % 1.0 version, and not the Connection: keep-alive header.
    receive closed -> ok end.

pre_1_1_server_keep_alive(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [
            fun pre_1_1_server_keep_alive/5,
            fun pre_1_1_server/5
        ]),
    URL = url(Port, "/close"),
    Body = pid_to_list(self()),
    {ok, Response1} = lhttpc:request(URL, get, [], [], 1000),
    {ok, Response2} = lhttpc:request(URL, put, [], Body, 1000),
    ?assertEqual({200, "OK"}, status(Response1)),
    ?assertEqual({200, "OK"}, status(Response2)),
    ?assertEqual(<<?DEFAULT_STRING>>, body(Response1)),
    ?assertEqual(<<?DEFAULT_STRING>>, body(Response2)),
    % Wait for the server to see that socket has been closed.
    % The socket should be closed by us since the server responded with a
    % 1.0 version, and not the Connection: keep-alive header.
    receive closed -> ok end.

simple_put(_Config) ->
    simple(put),
    simple("PUT").

post(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [fun copy_body/5]),
    URL = url(Port, "/post"),
    {X, Y, Z} = erlang:timestamp(),
    Body = [
        "This is a rather simple post :)",
        integer_to_list(X),
        integer_to_list(Y),
        integer_to_list(Z)
    ],
    {ok, Response} = lhttpc:request(URL, "POST", [], Body, 1000),
    {StatusCode, ReasonPhrase} = status(Response),
    ?assertEqual(200, StatusCode),
    ?assertEqual("OK", ReasonPhrase),
    ?assertEqual(iolist_to_binary(Body), body(Response)).

post_100_continue(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [fun copy_body_100_continue/5]),
    URL = url(Port, "/post"),
    {X, Y, Z} = erlang:timestamp(),
    Body = [
        "This is a rather simple post :)",
        integer_to_list(X),
        integer_to_list(Y),
        integer_to_list(Z)
    ],
    {ok, Response} = lhttpc:request(URL, "POST", [], Body, 1000),
    {StatusCode, ReasonPhrase} = status(Response),
    ?assertEqual(200, StatusCode),
    ?assertEqual("OK", ReasonPhrase),
    ?assertEqual(iolist_to_binary(Body), body(Response)).

persistent_connection(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [
            fun simple_response/5,
            fun simple_response/5,
            fun copy_body/5
        ]),
    URL = url(Port, "/persistent"),
    {ok, FirstResponse} = lhttpc:request(URL, "GET", [], 1000),
    Headers = [{"KeepAlive", "300"}], % shouldn't be needed
    {ok, SecondResponse} = lhttpc:request(URL, "GET", Headers, 1000),
    {ok, ThirdResponse} = lhttpc:request(URL, "POST", [], 1000),
    ?assertEqual({200, "OK"}, status(FirstResponse)),
    ?assertEqual(<<?DEFAULT_STRING>>, body(FirstResponse)),
    ?assertEqual({200, "OK"}, status(SecondResponse)),
    ?assertEqual(<<?DEFAULT_STRING>>, body(SecondResponse)),
    ?assertEqual({200, "OK"}, status(ThirdResponse)),
    ?assertEqual(<<>>, body(ThirdResponse)).

request_timeout(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [fun very_slow_response/5]),
    URL = url(Port, "/slow"),
    ?assertEqual({error, timeout}, lhttpc:request(URL, get, [], 50)).

connection_timeout(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [fun simple_response/5, fun simple_response/5]),
    URL = url(Port, "/close_conn"),
    lhttpc_manager:update_connection_timeout(lhttpc_manager, 50), % very short keep alive
    {ok, Response} = lhttpc:request(URL, get, [], 100),
    ?assertEqual({200, "OK"}, status(Response)),
    ?assertEqual(<<?DEFAULT_STRING>>, body(Response)),
    timer:sleep(100),
    ?assertEqual(0,
        lhttpc_manager:connection_count(lhttpc_manager, {"localhost", Port, false})),
    lhttpc_manager:update_connection_timeout(lhttpc_manager, 300000). % set back

suspended_manager(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [fun simple_response/5, fun simple_response/5]),
    URL = url(Port, "/persistent"),
    {ok, FirstResponse} = lhttpc:request(URL, get, [], 50),
    ?assertEqual({200, "OK"}, status(FirstResponse)),
    ?assertEqual(<<?DEFAULT_STRING>>, body(FirstResponse)),
    Pid = whereis(lhttpc_manager),
    true = erlang:suspend_process(Pid),
    ?assertEqual({error, timeout}, lhttpc:request(URL, get, [], 50)),
    true = erlang:resume_process(Pid),
    ?assertEqual(1,
        lhttpc_manager:connection_count(lhttpc_manager, {"localhost", Port, false})),
    {ok, SecondResponse} = lhttpc:request(URL, get, [], 50),
    ?assertEqual({200, "OK"}, status(SecondResponse)),
    ?assertEqual(<<?DEFAULT_STRING>>, body(SecondResponse)).

chunked_encoding(_Config) ->
    Port = webserver:start(?PROJECT_ROOT,
                           gen_tcp,
                           [fun chunked_response/5, fun chunked_response_t/5]),
    URL = url(Port, "/chunked"),
    {ok, FirstResponse} = lhttpc:request(URL, get, [], 50),
    ?assertEqual({200, "OK"}, status(FirstResponse)),
    ?assertEqual(<<?DEFAULT_STRING>>, body(FirstResponse)),
    ?assertEqual("chunked", lhttpc_lib:header_value("transfer-encoding",
            headers(FirstResponse))),
    {ok, SecondResponse} = lhttpc:request(URL, get, [], 50),
    ?assertEqual({200, "OK"}, status(SecondResponse)),
    ?assertEqual(<<"Again, great success!">>, body(SecondResponse)),
    ?assertEqual("ChUnKeD", lhttpc_lib:header_value("transfer-encoding",
            headers(SecondResponse))),
    ?assertEqual("1", lhttpc_lib:header_value("Trailer-1",
            headers(SecondResponse))),
    ?assertEqual("2", lhttpc_lib:header_value("Trailer-2",
            headers(SecondResponse))).

partial_upload_identity(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [fun simple_response/5, fun simple_response/5]),
    URL = url(Port, "/partial_upload"),
    Body = [<<"This">>, <<" is ">>, <<"chunky">>, <<" stuff!">>],
    Hdrs = [{"Content-Length", integer_to_list(iolist_size(Body))}],
    Options = [{partial_upload, 1}],
    {ok, UploadState1} = lhttpc:request(URL, post, Hdrs, hd(Body), 1000, Options),
    Response1 = lists:foldl(fun upload_parts/2, UploadState1,
        tl(Body) ++ [http_eob]),
    ?assertEqual({200, "OK"}, status(Response1)),
    ?assertEqual(<<?DEFAULT_STRING>>, body(Response1)),
    ?assertEqual("This is chunky stuff!",
        lhttpc_lib:header_value("x-test-orig-body", headers(Response1))),
    % Make sure it works with no body part in the original request as well
    {ok, UploadState2} = lhttpc:request(URL, post, Hdrs, [], 1000, Options),
    Response2 = lists:foldl(fun upload_parts/2, UploadState2,
        Body ++ [http_eob]),
    ?assertEqual({200, "OK"}, status(Response2)),
    ?assertEqual(<<?DEFAULT_STRING>>, body(Response2)),
    ?assertEqual("This is chunky stuff!",
        lhttpc_lib:header_value("x-test-orig-body", headers(Response2))).

partial_upload_identity_iolist(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [fun simple_response/5, fun simple_response/5]),
    URL = url(Port, "/partial_upload"),
    Body = ["This", [<<" ">>, $i, $s, [" "]], <<"chunky">>, [<<" stuff!">>]],
    Hdrs = [{"Content-Length", integer_to_list(iolist_size(Body))}],
    Options = [{partial_upload, 1}],
    {ok, UploadState1} = lhttpc:request(URL, post, Hdrs, hd(Body), 1000, Options),
    Response1 = lists:foldl(fun upload_parts/2, UploadState1,
        tl(Body) ++ [http_eob]),
    ?assertEqual({200, "OK"}, status(Response1)),
    ?assertEqual(<<?DEFAULT_STRING>>, body(Response1)),
    ?assertEqual("This is chunky stuff!",
        lhttpc_lib:header_value("x-test-orig-body", headers(Response1))),
    % Make sure it works with no body part in the original request as well
    {ok, UploadState2} = lhttpc:request(URL, post, Hdrs, [], 1000, Options),
    Response2 = lists:foldl(fun upload_parts/2, UploadState2,
        Body ++ [http_eob]),
    ?assertEqual({200, "OK"}, status(Response2)),
    ?assertEqual(<<?DEFAULT_STRING>>, body(Response2)),
    ?assertEqual("This is chunky stuff!",
        lhttpc_lib:header_value("x-test-orig-body", headers(Response2))).

-ifdef(SKIP_BROKEN_TEST_CASES).
partial_upload_chunked(_Config) ->
    {skip, "Broken test case"}.
-else.
partial_upload_chunked(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [fun chunked_upload/5, fun chunked_upload/5]),
    URL = url(Port, "/partial_upload_chunked"),
    Body = ["This", [<<" ">>, $i, $s, [" "]], <<"chunky">>, [<<" stuff!">>]],
    Options = [{partial_upload, 1}],
    {ok, UploadState1} = lhttpc:request(URL, post, [], hd(Body), 1000, Options),
    Trailer = {"X-Trailer-1", "my tail is tailing me...."},
    {ok, Response1} = lhttpc:send_trailers(
        lists:foldl(fun upload_parts/2, UploadState1, tl(Body)),
        [Trailer]
    ),
    ?assertEqual({200, "OK"}, status(Response1)),
    ?assertEqual(<<?DEFAULT_STRING>>, body(Response1)),
    ?assertEqual("This is chunky stuff!",
        lhttpc_lib:header_value("x-test-orig-body", headers(Response1))),
    ?assertEqual(element(2, Trailer),
        lhttpc_lib:header_value("x-test-orig-trailer-1", headers(Response1))),
    % Make sure it works with no body part in the original request as well
    Headers = [{"Transfer-Encoding", "chunked"}],
    {ok, UploadState2} = lhttpc:request(URL, post, Headers, [], 1000, Options),
    {ok, Response2} = lhttpc:send_trailers(
        lists:foldl(fun upload_parts/2, UploadState2, Body),
        [Trailer]
    ),
    ?assertEqual({200, "OK"}, status(Response2)),
    ?assertEqual(<<?DEFAULT_STRING>>, body(Response2)),
    ?assertEqual("This is chunky stuff!",
        lhttpc_lib:header_value("x-test-orig-body", headers(Response2))),
    ?assertEqual(element(2, Trailer),
        lhttpc_lib:header_value("x-test-orig-trailer-1", headers(Response2))).
-endif.

-ifdef(SKIP_BROKEN_TEST_CASES).
partial_upload_chunked_no_trailer(_Config) ->
    {skip, "Broken test case"}.
-else.
partial_upload_chunked_no_trailer(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [fun chunked_upload/5]),
    URL = url(Port, "/partial_upload_chunked_no_trailer"),
    Body = [<<"This">>, <<" is ">>, <<"chunky">>, <<" stuff!">>],
    Options = [{partial_upload, 1}],
    {ok, UploadState1} = lhttpc:request(URL, post, [], hd(Body), 1000, Options),
    {ok, Response} = lhttpc:send_body_part(
        lists:foldl(fun upload_parts/2, UploadState1, tl(Body)),
        http_eob
    ),
    ?assertEqual({200, "OK"}, status(Response)),
    ?assertEqual(<<?DEFAULT_STRING>>, body(Response)),
    ?assertEqual("This is chunky stuff!",
        lhttpc_lib:header_value("x-test-orig-body", headers(Response))).
-endif.

partial_download_illegal_option(_Config) ->
    ?assertError({bad_option, {partial_download, {foo, bar}}},
        lhttpc:request("http://localhost/", get, [], <<>>, 1000,
            [{partial_download, [{foo, bar}]}])).

partial_download_identity(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [fun large_response/5]),
    URL = url(Port, "/partial_download_identity"),
    PartialDownload = [
        {window_size, 1}
    ],
    Options = [{partial_download, PartialDownload}],
    {ok, {Status, _, Pid}} =
        lhttpc:request(URL, get, [], <<>>, 1000, Options),
    Body = read_partial_body(Pid),
    ?assertEqual({200, "OK"}, Status),
    ?assertEqual(<<?LONG_BODY_PART ?LONG_BODY_PART ?LONG_BODY_PART>>, Body).

partial_download_infinity_window(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [fun large_response/5]),
    URL = url(Port, "/partial_download_identity"),
    PartialDownload = [
        {window_size, infinity}
    ],
    Options = [{partial_download, PartialDownload}],
    {ok, {Status, _, Pid}} = lhttpc:request(URL, get, [], <<>>, 1000, Options),
    Body = read_partial_body(Pid),
    ?assertEqual({200, "OK"}, Status),
    ?assertEqual(<<?LONG_BODY_PART ?LONG_BODY_PART ?LONG_BODY_PART>>, Body).

partial_download_no_content_length(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [fun no_content_length/5]),
    URL = url(Port, "/no_cl"),
    PartialDownload = [
        {window_size, 1}
    ],
    Options = [{partial_download, PartialDownload}],
    {ok, {Status, _, Pid}} = lhttpc:request(URL, get, [], <<>>, 1000, Options),
    Body = read_partial_body(Pid),
    ?assertEqual({200, "OK"}, Status),
    ?assertEqual(<<?DEFAULT_STRING>>, Body).

partial_download_no_content(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [fun no_content_response/5]),
    URL = url(Port, "/partial_download_identity"),
    PartialDownload = [
        {window_size, 1}
    ],
    Options = [{partial_download, PartialDownload}],
    {ok, {Status, _, Body}} =
        lhttpc:request(URL, get, [], <<>>, 1000, Options),
    ?assertEqual({204, "OK"}, Status),
    ?assertEqual(undefined, Body).

limited_partial_download_identity(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [fun large_response/5]),
    URL = url(Port, "/partial_download_identity"),
    PartialDownload = [
        {window_size, 1},
        {part_size, 512} % bytes
    ],
    Options = [{partial_download, PartialDownload}],
    {ok, {Status, _, Pid}} =
        lhttpc:request(URL, get, [], <<>>, 1000, Options),
    Body = read_partial_body(Pid, 512),
    ?assertEqual({200, "OK"}, Status),
    ?assertEqual(<<?LONG_BODY_PART ?LONG_BODY_PART ?LONG_BODY_PART>>, Body).

partial_download_chunked(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [fun large_chunked_response/5]),
    URL = url(Port, "/partial_download_identity"),
    PartialDownload = [
        {window_size, 1},
        {part_size, length(?LONG_BODY_PART) * 3}
    ],
    Options = [{partial_download, PartialDownload}],
    {ok, {Status, _, Pid}} =
        lhttpc:request(URL, get, [], <<>>, 1000, Options),
    Body = read_partial_body(Pid),
    ?assertEqual({200, "OK"}, Status),
    ?assertEqual(<<?LONG_BODY_PART ?LONG_BODY_PART ?LONG_BODY_PART>>, Body).

partial_download_chunked_infinite_part(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [fun large_chunked_response/5]),
    URL = url(Port, "/partial_download_identity"),
    PartialDownload = [
        {window_size, 1},
        {part_size, infinity}
    ],
    Options = [{partial_download, PartialDownload}],
    {ok, {Status, _, Pid}} =
        lhttpc:request(URL, get, [], <<>>, 1000, Options),
    Body = read_partial_body(Pid),
    ?assertEqual({200, "OK"}, Status),
    ?assertEqual(<<?LONG_BODY_PART ?LONG_BODY_PART ?LONG_BODY_PART>>, Body).

partial_download_smallish_chunks(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [fun large_chunked_response/5]),
    URL = url(Port, "/partial_download_identity"),
    PartialDownload = [
        {window_size, 1},
        {part_size, length(?LONG_BODY_PART) - 1}
    ],
    Options = [{partial_download, PartialDownload}],
    {ok, {Status, _, Pid}} =
        lhttpc:request(URL, get, [], <<>>, 1000, Options),
    Body = read_partial_body(Pid),
    ?assertEqual({200, "OK"}, Status),
    ?assertEqual(<<?LONG_BODY_PART ?LONG_BODY_PART ?LONG_BODY_PART>>, Body).

partial_download_slow_chunks(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [fun slow_chunked_response/5]),
    URL = url(Port, "/slow"),
    PartialDownload = [
        {window_size, 1},
        {part_size, length(?LONG_BODY_PART) div 2}
    ],
    Options = [{partial_download, PartialDownload}],
    {ok, {Status, _, Pid}} = lhttpc:request(URL, get, [], <<>>, 1000, Options),
    Body = read_partial_body(Pid),
    ?assertEqual({200, "OK"}, Status),
    ?assertEqual(<<?LONG_BODY_PART ?LONG_BODY_PART>>, Body).

close_connection(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, gen_tcp, [fun close_connection/5]),
    URL = url(Port, "/close"),
    ?assertEqual({error, connection_closed}, lhttpc:request(URL, "GET", [], 1000)).

ssl_get(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, ssl, [fun simple_response/5]),
    URL = ssl_url(Port, "/simple"),
    {ok, Response} = lhttpc:request(URL, "GET", [], <<>>, 1000, [{verify_ssl_cert, false}]),
    ?assertEqual({200, "OK"}, status(Response)),
    ?assertEqual(<<?DEFAULT_STRING>>, body(Response)).

-ifdef(SKIP_IPV6_TEST_CASES).
ssl_get_ipv6(_Config) ->
    {skip, "IPv6 support not considered"}.
-else.
ssl_get_ipv6(_Config) ->
    case webserver:start(?PROJECT_ROOT, ssl, [fun simple_response/5], inet6) of
        {error, family_not_supported} ->
            % Localhost has no IPv6 support - not a big issue.
            {skip, "Impossible to test IPv6 support"};
        Port when is_number(Port) ->
            URL = ssl_url(inet6, Port, "/simple"),
            {ok, Response} = lhttpc:request(URL, "GET", [], <<>>, 1000, [{verify_ssl_cert, false}]),
            ?assertEqual({200, "OK"}, status(Response)),
            ?assertEqual(<<?DEFAULT_STRING>>, body(Response))
    end.
-endif.

ssl_post(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, ssl, [fun copy_body/5]),
    URL = ssl_url(Port, "/simple"),
    Body = "SSL Test <o/",
    BinaryBody = list_to_binary(Body),
    {ok, Response} = lhttpc:request(URL, "POST", [], Body, 1000, [{verify_ssl_cert, false}]),
    ?assertEqual({200, "OK"}, status(Response)),
    ?assertEqual(BinaryBody, body(Response)).

ssl_chunked(_Config) ->
    Port = webserver:start(?PROJECT_ROOT, ssl, [fun chunked_response/5, fun chunked_response_t/5]),
    URL = ssl_url(Port, "/ssl_chunked"),
    FirstResult = lhttpc:request(URL, get, [], <<>>, 100, [{verify_ssl_cert, false}]),
    ?assertMatch({ok, _}, FirstResult),
    {ok, FirstResponse} = FirstResult,
    ?assertEqual({200, "OK"}, status(FirstResponse)),
    ?assertEqual(<<?DEFAULT_STRING>>, body(FirstResponse)),
    ?assertEqual("chunked", lhttpc_lib:header_value("transfer-encoding",
            headers(FirstResponse))),
    SecondResult = lhttpc:request(URL, get, [], <<>>, 100, [{verify_ssl_cert, false}]),
    {ok, SecondResponse} = SecondResult,
    ?assertEqual({200, "OK"}, status(SecondResponse)),
    ?assertEqual(<<"Again, great success!">>, body(SecondResponse)),
    ?assertEqual("ChUnKeD", lhttpc_lib:header_value("transfer-encoding",
            headers(SecondResponse))),
    ?assertEqual("1", lhttpc_lib:header_value("Trailer-1",
            headers(SecondResponse))),
    ?assertEqual("2", lhttpc_lib:header_value("Trailer-2",
            headers(SecondResponse))).

connection_count(_Config) ->
    timer:sleep(50), % give the TCP stack time to deliver messages
    ?assertEqual(0, lhttpc_manager:connection_count(lhttpc_manager)).

%%% Helpers functions

upload_parts(BodyPart, CurrentState) ->
    {ok, NextState} = lhttpc:send_body_part(CurrentState, BodyPart, 1000),
    NextState.

read_partial_body(Pid) ->
    read_partial_body(Pid, infinity, []).

read_partial_body(Pid, Size) ->
    read_partial_body(Pid, Size, []).

read_partial_body(Pid, Size, Acc) ->
    case lhttpc:get_body_part(Pid) of
        {ok, {http_eob, []}} ->
            list_to_binary(Acc);
        {ok, Bin} ->
            if
                Size =:= infinity ->
                    ok;
                Size =/= infinity ->
                    ?assert(Size >= iolist_size(Bin))
            end,
            read_partial_body(Pid, Size, [Acc, Bin])
    end.

simple(Method) ->
    simple(Method, inet).

simple(Method, Family) ->
    case webserver:start(?PROJECT_ROOT, gen_tcp, [fun simple_response/5], Family) of
        {error, family_not_supported} when Family =:= inet6 ->
            % Localhost has no IPv6 support - not a big issue.
            {skip, "Impossible to test IPv6 support"};
        Port when is_number(Port) ->
            URL = url(Family, Port, "/simple"),
            {ok, Response} = lhttpc:request(URL, Method, [], 1000),
            {StatusCode, ReasonPhrase} = status(Response),
            ?assertEqual(200, StatusCode),
            ?assertEqual("OK", ReasonPhrase),
            ?assertEqual(<<?DEFAULT_STRING>>, body(Response))
    end.

url(Port, Path) ->
    url(inet, Port, Path).

url(inet, Port, Path) ->
    "http://localhost:" ++ integer_to_list(Port) ++ Path;
url(inet6, Port, Path) ->
    "http://[::1]:" ++ integer_to_list(Port) ++ Path.

url(Port, Path, User, Password) ->
    url(inet, Port, Path, User, Password).

url(inet, Port, Path, User, Password) ->
    "http://" ++ User ++ ":" ++ Password ++
        "@localhost:" ++ integer_to_list(Port) ++ Path;
url(inet6, Port, Path, User, Password) ->
    "http://" ++ User ++ ":" ++ Password ++
        "@[::1]:" ++ integer_to_list(Port) ++ Path.

ssl_url(Port, Path) ->
    "https://localhost:" ++ integer_to_list(Port) ++ Path.

ssl_url(inet6, Port, Path) ->
    "https://[::1]:" ++ integer_to_list(Port) ++ Path.

status({Status, _, _}) ->
    Status.

body({_, _, Body}) ->
    Body.

headers({_, Headers, _}) ->
    Headers.

%%% Responders
simple_response(Module, Socket, _Request, _Headers, Body) ->
    Module:send(
        Socket,
        [
            "HTTP/1.1 200 OK\r\n"
            "Content-type: text/plain\r\nContent-length: 14\r\n"
            "X-Test-Orig-Body: ", Body, "\r\n\r\n"
            ?DEFAULT_STRING
        ]
    ).

large_response(Module, Socket, _, _, _) ->
    BodyPart = <<?LONG_BODY_PART>>,
    ContentLength = 3 * size(BodyPart),
    Module:send(
        Socket,
        [
            "HTTP/1.1 200 OK\r\n"
            "Content-type: text/plain\r\n"
            "Content-length: ", integer_to_list(ContentLength), "\r\n\r\n"
        ]
    ),
    Module:send(Socket, BodyPart),
    Module:send(Socket, BodyPart),
    Module:send(Socket, BodyPart).

large_chunked_response(Module, Socket, _, _, _) ->
    BodyPart = <<?LONG_BODY_PART>>,
    ChunkSize = erlang:integer_to_list(size(BodyPart), 16),
    Chunk = [ChunkSize, "\r\n", BodyPart, "\r\n"],
    Module:send(
        Socket,
        [
            "HTTP/1.1 200 OK\r\n"
            "Content-type: text/plain\r\n"
            "Transfer-Encoding: chunked\r\n\r\n"
        ]
    ),
    Module:send(Socket, Chunk),
    Module:send(Socket, Chunk),
    Module:send(Socket, Chunk),
    Module:send(Socket, "0\r\n\r\n").

slow_chunked_response(Module, Socket, _, _, _) ->
    ChunkSize = erlang:integer_to_list(length(?LONG_BODY_PART) * 2, 16),
    Module:send(
        Socket,
        [
            "HTTP/1.1 200 OK\r\n"
            "Content-type: text/plain\r\n"
            "Transfer-Encoding: chunked\r\n\r\n"
        ]),
    Module:send(Socket, [ChunkSize, "\r\n", <<?LONG_BODY_PART>>]),
    timer:sleep(200),
    Module:send(Socket, [<<?LONG_BODY_PART>>, "\r\n"]),
    Module:send(Socket, "0\r\n\r\n").


chunked_upload(Module, Socket, _, Headers, <<>>) ->
    TransferEncoding = lhttpc_lib:header_value("transfer-encoding", Headers),
    {Body, HeadersAndTrailers} =
        webserver:read_chunked(Module, Socket, Headers),
    Trailer1 = lhttpc_lib:header_value("x-trailer-1", HeadersAndTrailers,
        "undefined"),
    Module:send(
        Socket,
        [
            "HTTP/1.1 200 OK\r\n"
            "Content-Length: 14\r\n"
            "X-Test-Orig-Trailer-1:", Trailer1, "\r\n"
            "X-Test-Orig-Enc: ", TransferEncoding, "\r\n"
            "X-Test-Orig-Body: ", Body, "\r\n\r\n"
            ?DEFAULT_STRING
        ]
    ).

head_response(Module, Socket, _Request, _Headers, _Body) ->
    Module:send(
        Socket,
        "HTTP/1.1 200 OK\r\n"
        "Server: Test server!\r\n\r\n"
    ).

no_content_response(Module, Socket, _Request, _Headers, _Body) ->
    Module:send(
        Socket,
        "HTTP/1.1 204 OK\r\n"
        "Server: Test server!\r\n\r\n"
    ).

empty_body(Module, Socket, _, _, _) ->
    Module:send(
        Socket,
        "HTTP/1.1 200 OK\r\n"
        "Content-type: text/plain\r\nContent-length: 0\r\n\r\n"
    ).

copy_body(Module, Socket, _, _, Body) ->
    Module:send(
        Socket,
        [
            "HTTP/1.1 200 OK\r\n"
            "Content-type: text/plain\r\nContent-length: "
            ++ integer_to_list(size(Body)) ++ "\r\n\r\n",
            Body
        ]
    ).

copy_body_100_continue(Module, Socket, _, _, Body) ->
    Module:send(
        Socket,
        [
            "HTTP/1.1 100 Continue\r\n\r\n"
            "HTTP/1.1 200 OK\r\n"
            "Content-type: text/plain\r\nContent-length: "
            ++ integer_to_list(size(Body)) ++ "\r\n\r\n",
            Body
        ]
    ).

respond_and_close(Module, Socket, _, _, Body) ->
    Pid = list_to_pid(binary_to_list(Body)),
    Module:send(
        Socket,
        "HTTP/1.1 200 OK\r\n"
        "Connection: close\r\n"
        "Content-type: text/plain\r\nContent-length: 14\r\n\r\n"
        ?DEFAULT_STRING
    ),
    {error, closed} = Module:recv(Socket, 0),
    Pid ! closed,
    Module:close(Socket).

respond_and_wait(Module, Socket, _, _, Body) ->
    Pid = list_to_pid(binary_to_list(Body)),
    Module:send(
        Socket,
        "HTTP/1.1 200 OK\r\n"
        "Content-type: text/plain\r\nContent-length: 14\r\n\r\n"
        ?DEFAULT_STRING
    ),
    % We didn't signal a connection close, but we want the client to do that
    % any way
    {error, closed} = Module:recv(Socket, 0),
    Pid ! closed,
    Module:close(Socket).

pre_1_1_server(Module, Socket, _, _, Body) ->
    Pid = list_to_pid(binary_to_list(Body)),
    Module:send(
        Socket,
        "HTTP/1.0 200 OK\r\n"
        "Content-type: text/plain\r\nContent-length: 14\r\n\r\n"
        ?DEFAULT_STRING
    ),
    % We didn't signal a connection close, but we want the client to do that
    % any way since we're 1.0 now
    {error, closed} = Module:recv(Socket, 0),
    Pid ! closed,
    Module:close(Socket).

pre_1_1_server_keep_alive(Module, Socket, _, _, _) ->
    Module:send(
        Socket,
        "HTTP/1.0 200 OK\r\n"
        "Content-type: text/plain\r\n"
        "Connection: Keep-Alive\r\n"
        "Content-length: 14\r\n\r\n"
        ?DEFAULT_STRING
    ).

very_slow_response(Module, Socket, _, _, _) ->
    timer:sleep(1000),
    Module:send(
        Socket,
        "HTTP/1.1 200 OK\r\n"
        "Content-type: text/plain\r\nContent-length: 14\r\n\r\n"
        ?DEFAULT_STRING
    ).

no_content_length(Module, Socket, _, _, _) ->
    Module:send(
        Socket,
        "HTTP/1.1 200 OK\r\n"
        "Content-type: text/plain\r\nConnection: close\r\n\r\n"
        ?DEFAULT_STRING
    ).

no_content_length_1_0(Module, Socket, _, _, _) ->
    Module:send(
        Socket,
        "HTTP/1.0 200 OK\r\n"
        "Content-type: text/plain\r\n\r\n"
        ?DEFAULT_STRING
    ).

chunked_response(Module, Socket, _, _, _) ->
    Module:send(
        Socket,
        "HTTP/1.1 200 OK\r\n"
        "Content-type: text/plain\r\nTransfer-Encoding: chunked\r\n\r\n"
        "5\r\n"
        "Great\r\n"
        "1\r\n"
        " \r\n"
        "8\r\n"
        "success!\r\n"
        "0\r\n"
        "\r\n"
    ).

chunked_response_t(Module, Socket, _, _, _) ->
    Module:send(
        Socket,
        "HTTP/1.1 200 OK\r\n"
        "Content-type: text/plain\r\nTransfer-Encoding: ChUnKeD\r\n\r\n"
        "7\r\n"
        "Again, \r\n"
        "E\r\n"
        "great success!\r\n"
        "0\r\n"
        "Trailer-1: 1\r\n"
        "Trailer-2: 2\r\n"
        "\r\n"
    ).

close_connection(Module, Socket, _, _, _) ->
    Module:send(
        Socket,
        "HTTP/1.1 200 OK\r\n"
        "Content-type: text/plain\r\nContent-length: 14\r\n\r\n"
    ),
    Module:close(Socket).

not_modified_response(Module, Socket, _Request, _Headers, _Body) ->
    Module:send(
        Socket,
        [
            "HTTP/1.1 304 Not Modified\r\n"
            "Date: Tue, 15 Nov 1994 08:12:31 GMT\r\n\r\n"
        ]
    ).

basic_auth_responder(User, Passwd) ->
    fun(Module, Socket, _Request, Headers, _Body) ->
        case proplists:get_value("Authorization", Headers) of
            undefined ->
                Module:send(
                    Socket,
                    [
                        "HTTP/1.1 401 Unauthorized\r\n",
                        "Content-Type: text/plain\r\n",
                        "Content-Length: 12\r\n\r\n",
                        "missing_auth"
                    ]
                );
            "Basic " ++ Auth ->
                [U, P] = string:tokens(
                    binary_to_list(base64:decode(iolist_to_binary(Auth))), ":"),
                case {U, P} of
                    {User, Passwd} ->
                        Module:send(
                            Socket,
                            [
                                "HTTP/1.1 200 OK\r\n",
                                "Content-Type: text/plain\r\n",
                                "Content-Length: 2\r\n\r\n",
                                "OK"
                            ]
                        );
                    _ ->
                        Module:send(
                            Socket,
                            [
                                "HTTP/1.1 401 Unauthorized\r\n",
                                "Content-Type: text/plain\r\n",
                                "Content-Length: 10\r\n\r\n",
                                "wrong_auth"
                            ]
                        )
                end
        end
    end.

trailing_space_header(Module, Socket, _, _, _) ->
    Module:send(
      Socket,
      "HTTP/1.1 200 OK\r\n"
          "Content-type: text/plain\r\n"
          "Content-Length: 14 \r\n\r\n"
          ?DEFAULT_STRING
    ).
