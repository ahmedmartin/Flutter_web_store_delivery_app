import 'dart:async';

import 'package:firebase_db_web_unofficial/DatabaseSnapshot.dart';
import 'package:flutter/material.dart';
import 'package:firebase_db_web_unofficial/firebasedbwebunofficial.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'classies/order.dart';
import 'home.dart';


class Send_seller_orders extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _Send_seller_orders();
  }

}

class _Send_seller_orders extends State<Send_seller_orders>{


  StreamSubscription <DatabaseSnapshot> adds;
  StreamSubscription <DatabaseSnapshot> updates;
  DatabaseRef ref ;
  List<order> seller_orders = [];
  String comp_id='comp_id';

  get_data()async{

    ref= FirebaseDatabaseWeb.instance.reference().child('companies').child(comp_id).child('mortg3');

    adds = ref.onChildAdded.listen((data) {
      Map map = data.value;

      map.forEach((key, value) {
        order Order = order.request(key,value['seller_name'],value['count']);
        Order.date = data.key;
        setState(() {
          seller_orders.add(Order);
        });
      });

    });
    updates = ref.onChildChanged.listen((data) {
      Map map = data.value;
      seller_orders.clear();
      map.forEach((key, value) {
        order Order = order.request(key,value['seller_name'],value['count']);
        Order.date = data.key;
        setState(() {
          seller_orders.add(Order);
        });
      });

    });
  }

  @override
  void initState() {
    get_data();
    super.initState();
  }

  @override
  void dispose() {
    adds.cancel();
    updates.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop:  ()async{Navigator.push(context,MaterialPageRoute(builder: (context)=> Home()));},
        child: Scaffold(
          body:  Padding(
            padding: EdgeInsets.all(10),
            child: ListView.builder(
                itemCount: seller_orders.length,
                itemBuilder: (context,index){
                  return GestureDetector(
                    child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(seller_orders[index].date,style: TextStyle(fontSize: 20,color: Colors.black)),
                                  Icon(Icons.calendar_today,color: Colors.black,size: 25,),
                                ],
                              ),
                              SizedBox(height: 10,),
                              Row(
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
                            ],
                          ),
                        )),
                    onTap: (){
                      get_orders(index);
                    },
                  );
                }),
          ) ,
        )
    );
  }

  get_orders(int index){
    show_progress();
    FirebaseFirestore.instance.collection('companies').doc(comp_id).collection('orders').doc(seller_orders[index].date).
    collection('all').where('seller_id',isEqualTo:seller_orders[index].seller_id).
    where('statuse',isNotEqualTo: 'استلم').get().then((snapshot){
      orders_list.clear();
      snapshot.docs.forEach((element) {
        order Order = order.send_seller(element['cust_name'],element['cust_phone'],element['cust_city'],
            element['cust_address'], element['cust_price'], element['cust_note'], element['statuse']);
           orders_list.add(Order);
      });
    }).whenComplete((){ Navigator.pop(context); show_mortg3_orders(index);}).
    timeout(Duration(seconds: 30)/*,onTimeout: (){Navigator.pop(context);}*/);
  }

  show_progress(){
    showDialog(
        context: context,
        builder: (context){
          return
          CircularProgressIndicator();/*AlertDialog(
            content: Center(
              child: CircularProgressIndicator(),
            ),
          );*/
        }
    );
  }

  List<order> orders_list =[];
  show_mortg3_orders(int i){
    showDialog(context: context, builder: (context) {
          bool waiting = false;
          return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: Text('تحديد المندوب'),
                  content: Center(
                      child:Column(
                        children: [
                         waiting? CircularProgressIndicator():Container(),
                          Container(
                            height: 370,
                            width: 400,
                            child: ListView.builder(
                                itemCount: orders_list.length ,
                                itemBuilder:(context,index){
                                  return Row_style(index,orders_list[index].cust_name, orders_list[index].cust_phone,
                                      orders_list[index].cust_address, orders_list[index].cust_note,
                                      orders_list[index].cust_city, orders_list[index].statuse);
                                }),
                          ),
                        ],
                      )
                  ),
                  actions: [
                FlatButton(
                    child: Text('تم الاستلام', style: TextStyle(fontSize: 30, color: Colors.white), textAlign: TextAlign.center,),
                    color: Colors.black,
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Colors.black)
                    ),
                    onPressed: () {
                      setState((){
                        waiting = true;
                      });
                    DocumentReference re =  FirebaseFirestore.instance.collection('sellers').doc(seller_orders[i].seller_id).collection('money')
                          .doc('all').collection(comp_id).doc(seller_orders[i].date);
                    re.get().then((snapshot){

                      String temp = '';

                      if(snapshot.data() != null) {
                        temp = snapshot.data()['money'];
                        re.update({'money': temp, 'mortg3': 'تم استلام المرتجع'}).whenComplete(() {
                          Navigator.pop(context);
                          ref.child(seller_orders[i].date).child(seller_orders[i].seller_id).remove();
                        });
                      }else{
                        re.set({'mortg3': 'تم استلام المرتجع'}).whenComplete(() {
                          Navigator.pop(context);
                          ref.child(seller_orders[i].date).child(seller_orders[i].seller_id).remove();
                        });
                      }
                    });
                    })
                  ],
                );
              });
        });
  }



  Widget Row_style(index,cust_name,cust_phone,cust_address,cust_note,String cust_city,statuse){

    return Card(
      color:Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 8,
      shadowColor: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(statuse,style: TextStyle(fontSize: 20,color: Colors.black),),
                    SizedBox(width: 10,),
                    Icon(Icons.assignment,color: Colors.black,size: 30,)
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(cust_name , style: TextStyle(fontSize: 20,color: Colors.black),),
                    Icon(Icons.person,color: Colors.black,size: 30,)
                  ],
                )
              ],
            ),

            //--------------------------------------------------------------------------------

            Container(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(cust_phone , style: TextStyle(fontSize: 20,color: Colors.black),),
                    Icon(Icons.phone,color: Colors.black,size: 30,)
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(cust_city, style: TextStyle(fontSize: 20,color: Colors.black),textAlign: TextAlign.center,),
                    Icon(Icons.map,color: Colors.black,size: 30,)
                  ],
                )

              ],
            ),

            //---------------------------------------------------------------------------------

            Container(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(cust_address,style: TextStyle(fontSize: 20,color: Colors.black),),
                Icon(Icons.person_pin_circle,color: Colors.black,size: 30,)
              ],
            ),

            Container(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(cust_note,style: TextStyle(fontSize: 20,color: Colors.black),),
                SizedBox(width: 10,),
                Icon(Icons.message,color: Colors.black,size: 30,)
              ],
            ),

          ],
        ),
      ),
    );
  }

}