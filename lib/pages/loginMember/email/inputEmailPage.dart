import 'package:auto_route/auto_route.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:readr/helpers/environment.dart';
import 'package:readr/helpers/router/router.dart';

class InputEmailPage extends StatefulWidget {
  @override
  _InputEmailPageState createState() => _InputEmailPageState();
}

class _InputEmailPageState extends State<InputEmailPage> {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        shadowColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Email',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate() && !_isSending) {
                _isSending = true;
                bool isSuccess = await LoginHelper().signInWithEmailAndLink(
                  _controller.text,
                  Environment().config.authlink,
                );
                if (isSuccess) {
                  AutoRouter.of(context)
                      .replace(SentEmailRoute(email: _controller.text));
                } else {
                  Fluttertoast.showToast(
                    msg: "Email寄送失敗",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    fontSize: 16.0,
                  );
                }
                _isSending = false;
              }
            },
            child: const Text(
              '送出',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _buildBody(context),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 24,
        ),
        Form(
          key: _formKey,
          child: TextFormField(
            keyboardType: TextInputType.emailAddress,
            autovalidateMode: AutovalidateMode.disabled,
            controller: _controller,
            validator: (value) {
              if (value != null) {
                if (value.isEmpty) {
                  return '請輸入您的 Email 地址';
                } else if (!isEmail(value)) {
                  return '請輸入有效的 Email 地址';
                }
              }
              return null;
            },
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(12.0),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black87, width: 1.0),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black26, width: 1.0),
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black26, width: 1.0),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        const Text(
          '我們會將登入連結寄送至這個 Email，替您省去設定密碼的麻煩。',
          style: TextStyle(
            fontSize: 13,
            color: Colors.black54,
            fontWeight: FontWeight.w400,
          ),
        )
      ],
    );
  }

  bool isEmail(String input) => EmailValidator.validate(input);
}