import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_db_web_unofficial/DatabaseSnapshot.dart';
import 'package:firebase_db_web_unofficial/firebasedbwebunofficial.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:ra7al_entry/send_delivery_orders.dart';
import 'package:ra7al_entry/send_seller_orders.dart';
import 'package:ra7al_entry/update_order.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'recieve_delivery_orders.dart';
import 'add_orders.dart';
import 'classies/order.dart';


class Home extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
      return _Home();
  }

}

class _Home extends State<Home>{

  StreamSubscription <DatabaseSnapshot> adds;
  StreamSubscription <DatabaseSnapshot> updates;
  StreamSubscription <DatabaseSnapshot> remove;
  DatabaseRef ref ;
  List<order> seller_orders = [];
  List<order> seller_name_list = [];
  //Map<String,List<order>> seller_orders_map = {};
  String comp_id='comp_id';

  DocumentReference comp_id_ref ;
  get_sellers(){
    comp_id_ref = FirebaseFirestore.instance.collection('companies').doc(comp_id);
    comp_id_ref.collection('sellers').get().then((snapshot){
      snapshot.docs.forEach((element) {
          seller_name_list.add(order.info(element['name'], element.id));
      });
    });
  }

  get_data()async{

    ref= FirebaseDatabaseWeb.instance.reference().child('companies').child(comp_id).child('requested_orders');

    adds = ref.onChildAdded.listen((data) {
      Map map = data.value;
      order Order = order.request(data.key,map['seller_name'],map['count']);
      setState(() {
        seller_orders.add(Order);
      });
    });

    updates = ref.onChildChanged.listen((data) {
      Map map = data.value;
      setState(() {
       seller_orders [seller_orders.indexWhere((element) => element.seller_id == data.key)].count = map['count'];
       seller_orders [seller_orders.indexWhere((element) => element.seller_id == data.key)].seller_name = map['seller_name'];
      });
    });

    remove = ref.onChildRemoved.listen((data) {
      setState(() {
        seller_orders.removeWhere((element) => element.seller_id == data.key);
      });
    });
  }

  @override
  void initState() {
    get_data();
    get_sellers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      drawer: Drawer(
        child: ListView(
          children: [
            Draw_header(),

            FlatButton(
              child: Text("اضافة اوردارات", style: TextStyle(fontSize: 25,color: Colors.black)),
              color: Colors.grey.withOpacity(0),
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder:(context)=> Add_orders('',seller_name_list)));
              },
            ),

            SizedBox(
              height: 10,
            ),
            FlatButton(
                child: Text("تعديل اوردارات",style: TextStyle(fontSize: 25,color: Colors.black),),
                color: Colors.grey.withOpacity(0),
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder:(context)=> Update_order()));
              },
            ),

            SizedBox(height: 10,),
            FlatButton(
              child: Text("تسليم مناديب", style: TextStyle(fontSize: 25,color: Colors.black),),
              color: Colors.grey.withOpacity(0),
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder:(context)=> Send_delivery_orders()));
              },
            ),
            SizedBox(height: 10,),
            FlatButton(
              child: Text("استلام من مناديب", style: TextStyle(fontSize: 25,color: Colors.black),),
              color: Colors.grey.withOpacity(0),
              onPressed: (){
                 Navigator.push(context, MaterialPageRoute(builder:(context)=> Recieve_delivery_orders()));
              },
            ),
            SizedBox(height: 10,),
            FlatButton(
              child: Text("استلام عدد الاوردارات", style: TextStyle(fontSize: 25,color: Colors.black),),
              color: Colors.grey.withOpacity(0),
              onPressed: (){
                show_recieve_seller_orders();
              },
            ),
            SizedBox(height: 10,),
            FlatButton(
              child: Text("تسليم مرتجاعات", style: TextStyle(fontSize: 25,color: Colors.black),),
              color: Colors.grey.withOpacity(0),
              onPressed: (){
                 Navigator.push(context, MaterialPageRoute(builder:(context)=> Send_seller_orders()));
              },
            ),
            SizedBox(height: 30,),
            FlatButton(
              child: Text("تسجيل الخروج" , style: TextStyle(fontSize: 22,color: Colors.black),),
              color: Colors.grey.withOpacity(0),
              onPressed: (){
               /* FirebaseAuth.instance.signOut().whenComplete((){
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (c)=>Login()), (route) => false);
                });*/
              },
            ),
          ],
        ),

      ),

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Ra7al',style: TextStyle(fontSize: 35,color: Colors.white),textAlign: TextAlign.center,),

      ),

      body: Padding(
        padding: EdgeInsets.all(10),
        child: ListView.builder(
            itemCount: seller_orders.length,
            itemBuilder: (context,index){
               return GestureDetector(
                 child: Card(
                     child: Padding(
                       padding: const EdgeInsets.all(10),
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                               Row(
                                 children: [
                                   Text(seller_orders[index].count,style: TextStyle(fontSize: 20,color: Colors.black)),
                                   Icon(Icons.notifications,color: Colors.black,size: 25,),
                                 ],
                               ),
                               Row(
                                 children: [
                                   Text(seller_orders[index].seller_name,style: TextStyle(fontSize: 20,color: Colors.black)),
                                   Icon(Icons.person,color: Colors.black,size: 25,)
                                 ],
                               ),

                          ],
                 ),
                     )),
                 onTap: (){
                   Navigator.push(context, MaterialPageRoute(builder: (context)=> Add_orders(seller_orders[index].seller_id,seller_name_list)));
                 },
               );
            }),
      ) ,

    );

  }

  Widget Draw_header(){
    return DrawerHeader(
      decoration: BoxDecoration(color: Colors.black),
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        //mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(height: 100,
            width: 110,
            child:CircleAvatar(backgroundImage: NetworkImage("https://images.squarespace-cdn.com/content/v1/5c528d9e96d455e9608d4c63/1586379635937-DUGHB6LHU59QIVDH2QHZ/ke17ZwdGBToddI8pDm48kHTW22EZ3GgW4oVLBBkxXg1Zw-zPPgdn4jUwVcJE1ZvWQUxwkmyExglNqGp0IvTJZUJFbgE-7XRK3dMEBRBhUpwEg94W6zd8FBNj5MCw-Ij7INTc0XdOQR2FYhNzGmPXJN9--qDehzI3YAaYB5CQ-LA/Hiker.gif?format=500w"),),
          ),

          SizedBox(width: 20,),

          Expanded(
            child: Text('Ra7al',style: TextStyle(fontSize: 30,color: Colors.white,fontWeight: FontWeight.bold),),
          ),

        ],
      ),
    );
  }

  
  show_recieve_seller_orders(){
    showDialog(
        context: context,
        builder: (context) {
          TextEditingController count_controller = TextEditingController();
          String selectedseller = "" ;
          return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                    title: Text('تحديد المندوب'), 
                    content: Center(
                        child: Column(
                            children: [
                              SearchableDropdown.single(
                                items: seller_name_list.map((val){
                                  return DropdownMenuItem(child: Text(val.seller_name),value: val.seller_name,);
                                }).toList(),
                                value: selectedseller,
                                hint: "اختار التاجر",
                                searchHint: "اختار التاجر",
                                onChanged: (value) {
                                  setState(() {
                                    selectedseller = value;
                                  });
                                },
                                isExpanded: true,
                              ),
                              SizedBox(height: 20,),
                              TextFormField(
                                decoration: InputDecoration(hintText: 'عدد الاوردارات المستلمه', 
                                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2), 
                                      borderRadius: BorderRadius.all(Radius.circular(30))), 
                                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2), 
                                      borderRadius: BorderRadius.all(Radius.circular(30))),
                                ),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black,fontSize: 20),
                            controller: count_controller,
                          ),
                        ])
                    ),
                    actions: [
                      FlatButton(
                          child: Text('نعم',
                            style: TextStyle(fontSize: 30, color: Colors.white),
                            textAlign: TextAlign.center,),
                          color: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide(color: Colors.black)
                          ),
                          onPressed: () {
                            if(selectedseller.isNotEmpty && count_controller.text.isNotEmpty) {
                              String seller_id = seller_name_list[seller_name_list.indexWhere((item) => item.seller_name == selectedseller)].seller_id;
                              ref.child(seller_id).set({'count': count_controller.text, 'seller_name': selectedseller})
                              .whenComplete((){Navigator.pop(context);});
                            }
                          })
                    ],
                );
              });
        });
  }

}