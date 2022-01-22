import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:readr/configs/devConfig.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/environment.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/graphqlBody.dart';
import 'package:readr/models/member.dart';

class MemberService {
  final ApiBaseHelper _helper = ApiBaseHelper();
  // TODO: Change to Environment config when all environment built
  final String api = DevConfig().keystoneApi;

  Future<Map<String, String>> getHeaders({bool needAuth = true}) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    if (needAuth) {
      // TODO: Change back to firebase token when verify firebase token is finished
      String token = await _fetchCMSUserToken();
      //String token = await FirebaseAuth.instance.currentUser!.getIdToken();
      headers.addAll({"Authorization": "Bearer $token"});
    }

    return headers;
  }

  // Get READr CMS User token for authorization
  // TODO: Delete when verify firebase token is finished
  Future<String> _fetchCMSUserToken() async {
    String mutation = """
    mutation(
	    \$email: String!,
	    \$password: String!
    ){
	    authenticateUserWithPassword(
		    email: \$email
		    password: \$password
      ){
        ... on UserAuthenticationWithPasswordSuccess{
        	sessionToken
      	}
        ... on UserAuthenticationWithPasswordFailure{
          message
      	}
      }
    }
    """;

    Map<String, String> variables = {
      "email": DevConfig().appHelperEmail,
      "password": DevConfig().appHelperPassword,
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: mutation,
      variables: variables,
    );

    final jsonResponse = await _helper.postByUrl(
        api, jsonEncode(graphqlBody.toJson()),
        headers: {"Content-Type": "application/json"});

    String token =
        jsonResponse['data']['authenticateUserWithPassword']['sessionToken'];

    return token;
  }

  Future<Member> fetchMemberData() async {
    const String query = """
    query(
      \$firebaseId: String
    ){
      members(
        where:{
          firebaseId: {
            equals: \$firebaseId
          }
        }
      ){
        id
        nickname
        firebaseId
        email
        avatar
        verified
        following(
          where: {
            is_active: {
              equals: true
            }
          }
        ){
          id
          nickname
        }
        following_category{
          id
          slug
          title
        }
        follow_publisher{
          id
          title
        }
      }
    }
    """;

    Map<String, dynamic> variables = {
      "firebaseId": FirebaseAuth.instance.currentUser!.uid,
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final dynamic jsonResponse;
    jsonResponse = await _helper.postByUrl(
      api,
      jsonEncode(graphqlBody.toJson()),
      headers: await getHeaders(needAuth: false),
    );

    // create new member when firebase is signed in but member is not created
    if (jsonResponse['data']['members'].isEmpty) {
      Member? newMember = await createMember();
      return newMember;
    } else {
      return Member.fromJson(jsonResponse['data']['members'][0]);
    }
  }

  Future<Member> createMember() async {
    String mutation = """
    mutation (
	    \$email: String
	    \$firebaseId: String
  		\$name: String
  		\$nickname: String
  		\$verify: Boolean
  		\$avatar: String
    ){
	    createMember(
		    data: { 
			    email: \$email,
			    firebaseId: \$firebaseId,
          name: \$name,
          nickname: \$nickname,
          is_active: true,
          verified: \$verify,
          avatar: \$avatar
		    }) {
        id
        nickname
        firebaseId
        email
        avatar
        verified
        following(
          where: {
            is_active: {
              equals: true
            }
          }
        ){
          id
          nickname
        }
        following_category{
          id
          slug
          title
        }
        follow_publisher{
          id
          title
        }
      }
    }
    """;

    User firebaseUser = FirebaseAuth.instance.currentUser!;

    // if facebook authUser has no email,then feed email field with prompt
    String feededEmail =
        firebaseUser.email ?? '[0x0001] - firebaseId:${firebaseUser.uid}';

    String nickname;
    if (firebaseUser.displayName != null) {
      nickname = firebaseUser.displayName!;
    } else if (firebaseUser.email != null) {
      nickname = firebaseUser.email!.split('@')[0];
    } else {
      var splitUid = firebaseUser.uid.split('');
      String randomName = '';
      for (int i = 0; i < 5; i++) {
        randomName = randomName + splitUid[i];
      }
      nickname = 'User $randomName';
    }

    Map<String, String> variables = {
      "email": feededEmail,
      "firebaseId": firebaseUser.uid,
      "name": nickname,
      "nickname": nickname,
      "verify": firebaseUser.emailVerified.toString(),
      "avatar": firebaseUser.photoURL ?? ""
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: mutation,
      variables: variables,
    );

    final jsonResponse = await _helper.postByUrl(
      api,
      jsonEncode(graphqlBody.toJson()),
      headers: await getHeaders(),
    );

    return Member.fromJson(jsonResponse['data']['createMember']);
  }

  Future<bool> deleteMember(String memberId, String token) async {
    String mutation = """
    mutation(
      \$id: ID
    ){
      updateMember(
        where:{
          id: \$id
        }
        data:{
          is_active: false
        }
      ){
        is_active
      }
    }
    """;
    Map<String, String> variables = {"id": memberId};

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: mutation,
      variables: variables,
    );

    try {
      final jsonResponse = await _helper.postByUrl(
        api,
        jsonEncode(graphqlBody.toJson()),
        headers: await getHeaders(),
      );

      return !jsonResponse.containsKey('errors');
    } catch (e) {
      return false;
    }
  }

  Future<List<Member>?> addFollowingMember(
      String memberId, String targetMemberId) async {
    String mutation = """
    mutation(
      \$memberId: ID
      \$targetMemberId: ID
    ){
      updateMember(
        where:{
          id: \$memberId
        }
        data:{
          following:{
            connect:{
              id: \$targetMemberId
            } 
          }
        }
      ){
        following{
          id
          nickname
        }
      }
    }
    """;
    Map<String, String> variables = {
      "memberId": memberId,
      "targetMemberId": targetMemberId
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: mutation,
      variables: variables,
    );

    try {
      final jsonResponse = await _helper.postByUrl(
        api,
        jsonEncode(graphqlBody.toJson()),
        headers: await getHeaders(),
      );

      if (jsonResponse.containsKey('errors')) {
        return null;
      }
      List<Member> followingMembers = [];
      for (var member in jsonResponse['data']['updateMember']['following']) {
        followingMembers.add(Member.fromJson(member));
      }

      return followingMembers;
    } catch (e) {
      return null;
    }
  }

  Future<List<Member>?> removeFollowingMember(
      String memberId, String targetMemberId) async {
    String mutation = """
    mutation(
      \$memberId: ID
      \$targetMemberId: ID
    ){
      updateMember(
        where:{
          id: \$memberId
        }
        data:{
          following:{
            disconnect:{
              id: \$targetMemberId
            } 
          }
        }
      ){
        following{
          id
          nickname
        }
      }
    }
    """;
    Map<String, String> variables = {
      "memberId": memberId,
      "targetMemberId": targetMemberId
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: mutation,
      variables: variables,
    );

    try {
      final jsonResponse = await _helper.postByUrl(
        api,
        jsonEncode(graphqlBody.toJson()),
        headers: await getHeaders(),
      );

      if (jsonResponse.containsKey('errors')) {
        return null;
      }
      List<Member> followingMembers = [];
      for (var member in jsonResponse['data']['updateMember']['following']) {
        followingMembers.add(Member.fromJson(member));
      }

      return followingMembers;
    } catch (e) {
      return null;
    }
  }
}
