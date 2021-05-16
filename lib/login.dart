import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home.dart';

class Login extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _Login();
  }


}

class _Login extends State<Login>{

  TextEditingController email_controller = TextEditingController();
  TextEditingController pass_controller = TextEditingController();
  var listener ;
  @override
  void initState() {
    listener = FirebaseAuth.instance.authStateChanges().listen((User user) {
      if (user != null) {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (c)=>Home()), (route) => false);
        listener.cancel();
        print('signed in!');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          TextFormField(
          controller: email_controller,
          decoration: InputDecoration(hintText: "البريد الالكترونى",
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                borderRadius: BorderRadius.all(Radius.circular(30))),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                borderRadius: BorderRadius.all(Radius.circular(30))),
          ),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20,color: Colors.black),
          ),

          SizedBox(height: 20,),
          TextFormField(
            obscuringCharacter: "*",
            obscureText: true,
            controller: pass_controller,
            decoration: InputDecoration(hintText: "الرقم السرى",
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                  borderRadius: BorderRadius.all(Radius.circular(30))),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                  borderRadius: BorderRadius.all(Radius.circular(30))),
            ),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20,color: Colors.black),
          ),

          SizedBox(height: 20,),
          RaisedButton(

              color:  Colors.black ,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(color: Colors.black)
              ),
              child: Text('تسجيل الدخول',style: TextStyle(fontSize: 20,color: Colors.white),textAlign: TextAlign.center,),
              onPressed: () async {

                if(email_controller.text.isNotEmpty) {
                  if(pass_controller.text.isNotEmpty) {

                    try {
                       await FirebaseAuth.instance.signInWithEmailAndPassword(email: email_controller.text, password: pass_controller.text
                      );
                    } on FirebaseAuthException catch (e) {
                      print(e.message);
                      if (e.code == 'user-not-found') {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("البريد الالكترونى غير صحيح او غير موجود",style: TextStyle(fontSize: 40),textAlign: TextAlign.center,),
                          backgroundColor: Colors.black,
                        ));

                      } else if (e.code == 'wrong-password') {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("الرقم السرى غير صحيح",style: TextStyle(fontSize: 40),textAlign: TextAlign.center,),
                          backgroundColor: Colors.black,
                        ));
                      } else{
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(e.message,style: TextStyle(fontSize: 40),textAlign: TextAlign.center,),
                          backgroundColor: Colors.black,
                        ));
                      }
                    }
                  }else{
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("يجب كتابه الرقم السرى",style: TextStyle(fontSize: 40),textAlign: TextAlign.center,),
                      backgroundColor: Colors.black,
                    ));
                  }
                }else{
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("يجب كتابه البريد الالكترونى",style: TextStyle(fontSize: 40),textAlign: TextAlign.center,),
                    backgroundColor: Colors.black,
                  ));
                }
              })
          ],
        ),
      ),
    );
  }
}
