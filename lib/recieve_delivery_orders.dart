import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'classies/city_country.dart';
import 'classies/order.dart';
import 'home.dart';



class Recieve_delivery_orders extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _Recieve_delivery_orders();
  }

}


class _Recieve_delivery_orders extends State<Recieve_delivery_orders>{


  List<order> delivery_name_list = [];
  List<order> all_orders =[];
  List<order> search_orders = [];
  List<String> city = city_country().city;

  String city_selected;
  String selected_delivery_name;
  String comp_id = 'comp_id';
  String date ="" ;
  int orders_count = 0;
  bool download_orders = false;
  TextEditingController controller_cust_phone = TextEditingController();

  
  get_date(){
    FirebaseFirestore.instance.collection('companies').doc(comp_id).collection('orders')
        .where('last_date',isEqualTo: 'yes').get().then((snapshot){
          snapshot.docs.forEach((element) {
            setState(() {
              date = element.id;
            });


          });
    });
  }


  get_deliveries(String delivery_id){

    FirebaseFirestore.instance.collection('companies').doc(comp_id).collection('deliveries').doc(delivery_id).get().then((snapshot){

        setState(() {
          delivery_name_list[delivery_name_list.indexWhere((element) => element.seller_id==delivery_id)].seller_name = snapshot.data()['name'] ;
        });
    });
  }

  @override
  void initState() {
    get_date();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: ()async{Navigator.push(context,MaterialPageRoute(builder: (context)=> Home()));},
        child: Scaffold(
          body:Column(
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    child: DropdownButton(
                        hint: Text("اختار المندوب"),
                        items: delivery_name_list.map((val){
                          return DropdownMenuItem(child: Text(val.seller_name),value: val.seller_name,);
                        }).toList(),
                        value: selected_delivery_name,
                        onChanged: (val){
                          setState(() {
                            selected_delivery_name = val;
                            search_orders.clear();
                            for(int i=0;i<all_orders.length;i++){
                              if(all_orders[i].delivery_id == delivery_name_list[delivery_name_list.indexWhere((element) => element.seller_name == val)].seller_id){
                                search_orders.add(all_orders[i]);
                              }
                            }
                            orders_count = search_orders.length;
                          });
                        }),
                  ),
                  Flexible(
                    child: DropdownButton(
                        hint: Text("اختار المحافظه"),
                        items: city.map((val){
                          return DropdownMenuItem(child: Text(val),value: val,);
                        }).toList(),
                        value: city_selected,
                        onChanged: (val){
                          setState(() {
                            city_selected = val;
                            download_orders=true;
                            get_orders();
                          });
                        }),
                  ),
                ],
              ),

              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FlatButton(
                        color: Colors.black.withOpacity(0),
                        child: Text('استلام كل الاوردارات للمندوب المحدد',style: TextStyle(fontSize: 15,color: Colors.black),),
                        onPressed: (){
                          recieve_all_orders_from_delivery();
                        },
                      ),
                      SizedBox(width: 10,),
                      Icon(Icons.menu,color: Colors.black,size: 30),

                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(date,style: TextStyle(fontSize: 20,color: Colors.black),),
                      SizedBox(width: 10,),
                      Icon(Icons.calendar_today_sharp,color: Colors.black,size: 30),

                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(orders_count.toString(),style: TextStyle(fontSize: 20,color: Colors.black),),
                      SizedBox(width: 10,),
                      Icon(Icons.assessment,color: Colors.black,size: 30),

                    ],
                  ),
                ],
              ),

              SizedBox(height: 20,),
              TextFormField(
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(hintText: 'تليفون العميل او الحاله',
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    suffixIcon: Icon(Icons.search,size: 30,color: Colors.black,)
                ),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black,fontSize: 20),
                controller: controller_cust_phone,
                onChanged: (value){

                  setState(() {
                    search_orders.clear();
                   // search for cust phone number
                    search_orders.addAll(all_orders.where((element) => element.cust_phone.contains(value)));
                   // search for statuse with delivery
                    if(selected_delivery_name!=null && value.isNotEmpty)
                     search_orders.addAll(all_orders.where((element) => element.statuse.contains(value)
                         && element.delivery_id == delivery_name_list[delivery_name_list.indexWhere((item) => item.seller_name ==selected_delivery_name )].seller_id ));

                    orders_count = search_orders.length;
                  });

                },
              ),

              SizedBox(height: 20,),
              download_orders?CircularProgressIndicator():Container(),

              SizedBox(height: 20,),
              Flexible(
                  child: ListView.builder(
                      itemCount: search_orders.length,
                      itemBuilder:(context,index){
                        return GestureDetector(
                          child: Row_style(index, search_orders[index].cust_name, search_orders[index].cust_phone,
                              search_orders[index].cust_address, search_orders[index].cust_note, search_orders[index].cust_price,
                              search_orders[index].cust_city, search_orders[index].delivery_fee_plus,search_orders[index].statuse) ,
                          onTap: (){
                            show_accept_recieved_order_from_delivery(index);
                          },
                        );
                      })

              ),

            ],
          ) ,
        )
    );
  }

  get_orders(){
    setState(() {
      controller_cust_phone.text="";
      all_orders.clear();
      search_orders.clear();
      delivery_name_list.clear();
      selected_delivery_name = null;
    });
   Query ref = FirebaseFirestore.instance.collection('companies').doc(comp_id).collection('waiting_orders')
        .where('cust_city',isEqualTo:city_selected );
    ref = ref.where('statuse',whereIn: ['شحن على الراسل','مؤجل','مرتجع جزئى','مرتجع','قيد التنفيذ']);
    ref = ref.where('delivery_id',isNotEqualTo:'');
    ref.get().then((snapshot){
        if(snapshot.docs.isEmpty){
          print(snapshot.docs.length);
          setState(() {
            download_orders=false;
            orders_count = search_orders.length;
          });
      }
      snapshot.docs.forEach((element) {
        order Order = order.recieve_from_delivery(element.data()['cust_name'],element.data()['cust_phone'], element.data()['cust_city'],
            element.data()['cust_address'], element.data()['cust_price'], element.data()['cust_note'],
            element.data()['delivery_id'], element.data()['seller_id'],element.data()['delivery_fee_plus']
            ,element.id,element.data()['statuse'],element.data()['cust_delivery_price']);

        // get delivery who have orders in this city

        if(! delivery_name_list.any((item) => item.seller_id == element.data()['delivery_id'] )) {
          delivery_name_list.add(order.info('',element.data()['delivery_id'] ));
          get_deliveries(element.data()['delivery_id']);
        }
        setState(() {
          all_orders.add(Order);
          search_orders.add(Order);
          download_orders=false;
          orders_count = search_orders.length;
        });

      });
    });
  }

  Widget Row_style(index,cust_name,cust_phone,cust_address,cust_note,cust_price,String cust_city,delivery_fee_plus,statuse){

    int temp_index = delivery_name_list.indexWhere((element) => element.seller_id == search_orders[index].delivery_id);

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
                    Text(temp_index!= -1? delivery_name_list[temp_index].seller_name:"",style: TextStyle(fontSize: 20,color: Colors.black),),
                    SizedBox(width: 10,),
                    Icon(Icons.directions_car,color: Colors.black,size: 30,)
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(cust_price,style: TextStyle(fontSize: 20,color: Colors.green),),
                    SizedBox(width: 10,),
                    Icon(Icons.attach_money,color: Colors.green,size: 30,)
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(delivery_fee_plus,style: TextStyle(fontSize: 20,color: Colors.red),),
                    SizedBox(width: 10,),
                    Icon(Icons.add_shopping_cart,color: Colors.red,size: 30,)
                  ],
                ),
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

          ],
        ),
      ),
    );
  }

  show_accept_recieved_order_from_delivery(int index){
    int temp_index = delivery_name_list.indexWhere((element) => element.seller_id == search_orders[index].delivery_id);
      showDialog(
          context: context,
          builder: (context) {
            bool waiting = false;
            return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: Text('استلام من المندوب'),
                    content: Center(
                      child: Column(
                        children: [
                          SizedBox(height: 5,),
                          Text('هل تريد استلام الاوردر صاحب الرقم', style: TextStyle(color: Colors.black, fontSize: 20),),
                          SizedBox(height: 5,),
                          Text(search_orders[index].cust_phone, style: TextStyle(color: Colors.black, fontSize: 20),),
                          SizedBox(height: 10,),
                          Text(delivery_name_list[temp_index].seller_name+" من المندوب ", style: TextStyle(color: Colors.black, fontSize: 20),),
                          SizedBox(height: 10,),
                          Text(' ؟ '+date+' بتاريخ ', style: TextStyle(color: Colors.black, fontSize: 20),),
                          SizedBox(height: 20,),
                          waiting ? CircularProgressIndicator() : Container(),
                        ],
                      ),
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
                            setState(() {
                              waiting = true;
                            });

                            if(search_orders[index].statuse == 'مؤجل'||search_orders[index].statuse == 'قيد التنفيذ'){
                              search_orders[index].delivery_id = '' ;
                              print(search_orders[index].order_id);
                              FirebaseFirestore.instance.collection('companies').doc(comp_id).collection('waiting_orders')
                                  .doc(search_orders[index].order_id).update(search_orders[index].to_map()).whenComplete(() {

                                    all_orders.removeWhere((element) => element.delivery_id == '' &&
                                        element.cust_phone == search_orders[index].cust_phone &&
                                        element.seller_id == search_orders[index].seller_id);

                                    search_orders.removeAt(index);
                                    update_ui();
                                    Navigator.pop(context);

                              });

                            }else {
                              FirebaseFirestore.instance.collection('companies').doc(comp_id).collection('orders')
                                  .doc(date).collection('all').add(search_orders[index].to_map()).whenComplete(() {

                                    // delet order from waiting_orders after move to completed orders (orders)
                                 FirebaseFirestore.instance.collection('companies').doc(comp_id).collection('waiting_orders')
                                    .doc(search_orders[index].order_id).delete();

                                    // remove order from (search,all)_order_list and update ui
                                  all_orders.removeWhere((element) => element.delivery_id == '' &&
                                    element.cust_phone == search_orders[index].cust_phone &&
                                    element.seller_id == search_orders[index].seller_id);

                                search_orders.removeAt(index);
                                update_ui();
                                Navigator.pop(context);
                              });
                            }
                          })
                    ],
                  );
                });
          });


  }

  update_ui(){
    setState(() {
      search_orders = search_orders;
      orders_count = search_orders.length;
    });
  }

  recieve_all_orders_from_delivery(){

    if(selected_delivery_name!= null){
      showDialog(
          context: context,
          builder: (context) {
            bool waiting = false;
            return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: Text('استلام من المندوب'),
                    content: Center(
                      child: Column(
                        children: [
                          SizedBox(height: 10,),
                          Text('هل تريد استلام كل الاوردارات المحدده ', style: TextStyle(color: Colors.black, fontSize: 20),),
                          Text(selected_delivery_name+" من المندوب ", style: TextStyle(color: Colors.black, fontSize: 20),),
                          Text(' ؟ '+date+' بتاريخ ', style: TextStyle(color: Colors.black, fontSize: 20),),
                          SizedBox(height: 20,),
                          waiting ? CircularProgressIndicator() : Container(),
                        ],
                      ),
                    ),
                    actions: [
                      FlatButton(
                          child: Text('نعم', style: TextStyle(fontSize: 30, color: Colors.white), textAlign: TextAlign.center,),
                          color: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide(color: Colors.black)
                          ),
                          onPressed: () {
                            setState(() {
                              waiting = true;
                            });
                            if(search_orders.isNotEmpty) {
                              String temp_delivery_id = search_orders[0].delivery_id;
                              for (int i = 0; i < search_orders.length; i++) {
                                  if(search_orders[i].statuse == 'مؤجل'||search_orders[i].statuse == 'قيد التنفيذ') {
                                    search_orders[i].delivery_id = '';
                                    FirebaseFirestore.instance.collection('companies').doc(comp_id).collection('waiting_orders')
                                        .doc(search_orders[i].order_id).update(search_orders[i].to_map()).whenComplete(() {
                                      if (i == search_orders.length - 1) {
                                        search_orders.clear();
                                        all_orders.removeWhere((element) => element.delivery_id == temp_delivery_id);
                                        all_orders.removeWhere((element) => element.delivery_id == '');
                                        update_ui();
                                        Navigator.pop(context);
                                      }
                                    });
                                  }else {
                                    FirebaseFirestore.instance.collection('companies').doc(comp_id).collection('orders')
                                        .doc(date).collection('all').add(search_orders[i].to_map()).whenComplete(() {

                                      // delet order from waiting_orders after move to completed orders (orders)
                                      FirebaseFirestore.instance.collection('companies').doc(comp_id).collection('waiting_orders')
                                          .doc(search_orders[i].order_id).delete().whenComplete((){

                                            // remove order from (search,all)_order_list and update ui
                                        if (i == search_orders.length - 1) {
                                          all_orders.removeWhere((element) => element.delivery_id == temp_delivery_id);
                                          all_orders.removeWhere((element) => element.delivery_id == '' );
                                          search_orders.clear();
                                          update_ui();
                                          Navigator.pop(context);
                                        }

                                      });

                                    });
                                  }
                              }

                            }else{
                              Navigator.pop(context);
                              Flushbar(
                                title: "ملاحظه",
                                message: "لا يمتلك هذا المندوب اوردارات",
                                duration: Duration(seconds: 3),
                              )..show(context);
                            }
                          })
                    ],
                  );
                });
          });
    }else{
      Flushbar(
        title: "ملاحظه",
        message: "يجب اختيار مندوب",
        duration: Duration(seconds: 3),
      )..show(context);
    }

  }

}