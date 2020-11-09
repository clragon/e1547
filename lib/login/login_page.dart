import 'package:flutter/material.dart';

import 'components/form_fields.dart';
import 'components/tutorial_steps.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Form(
              child: Column(children: [
            TutorialSteps(),
            LoginFields(),
          ]))),
    );
  }
}
