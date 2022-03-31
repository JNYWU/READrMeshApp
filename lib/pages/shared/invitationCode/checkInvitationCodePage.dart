import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/invitationCode/invitationCode_cubit.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/pages/shared/invitationCode/checkInvitationCodeWidget.dart';

class CheckInvitationCodePage extends StatelessWidget {
  const CheckInvitationCodePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0.5,
        backgroundColor: Colors.white,
        title: const Text(
          '邀請碼',
          style: TextStyle(
            color: readrBlack,
            fontWeight: FontWeight.w400,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.close,
              size: 26,
              color: readrBlack87,
            ),
          )
        ],
      ),
      body: SafeArea(
        child: BlocProvider(
          create: (context) => InvitationCodeCubit(),
          child: CheckInvitationCodeWidget(),
        ),
      ),
    );
  }
}
