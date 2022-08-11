import 'dart:async';

import 'package:energizers/global/GlobalVars.dart';
import 'package:flutter/material.dart';
import 'package:graphql/client.dart' as prefix0;
import 'package:graphql/internal.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

GraphQLClient initGraphQL({String accessToken}) {
  final HttpLink _httpLink = HttpLink(
    uri: "https://energizers.foremanoils.com/api/v1/graphql",
  );

  final AuthLink _authLink = AuthLink(
    getToken: () async => 'Bearer $accessToken',
  );

  final Link _link = _authLink.concat(_httpLink);

  return GraphQLClient(
    cache: InMemoryCache(),
//    cache: ,
    link: _link,
  );
}

ValueNotifier<GraphQLClient> initGraphQLWidget({String accessToken}) {
  final HttpLink _httpLink = HttpLink(
    uri: "https://energizers.foremanoils.com/api/v1/graphql",
  );

  final AuthLink _authLink = AuthLink(
    getToken: () async => 'Bearer $accessToken',
  );

  final Link _link = _authLink.concat(_httpLink);

  return ValueNotifier(GraphQLClient(
    cache: InMemoryCache(),
    link: _link,
  ));
}
