
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'classies/city_country.dart';
import 'classies/order.dart';
import 'home.dart';


class Send_delivery_orders extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _Send_delivery_orders();
  }
}

class _Send_delivery_orders extends State<Send_delivery_orders>{
 
  String selected_delivery_name ;
  String comp_id = 'comp_id';
  String city_selected;
  int orders_count =0;
  List<order> delivery_name_list = [];
  List<String> city = city_country().city;

  TextEditingController controller_cust_phone = TextEditingController();
  List<order> all_orders =[];
  List<order> search_orders = [];
  bool download_orders = false;

  get_deliveries(){
    
    FirebaseFirestore.instance.collection('companies').doc(comp_id).collection('deliveries').get().then((snapshot){

      snapshot.docs.forEach((element) {
        order Order = order.info(element.data()['name'], element.id);
        setState(() {
          delivery_name_list.add(Order);
        });
      });
    });
  }

  @override
  void initState() {
    get_deliveries();
    super.initState();
  }
 
  @override
  Widget build(BuildContext context) {
    
    return WillPopScope(
        onWillPop: ()async{Navigator.push(context,MaterialPageRoute(builder: (context)=> Home()));},
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [

                    Flexible(
                      child: SearchableDropdown.single(
                        items: delivery_name_list.map((val){
                          return DropdownMenuItem(child: Text(val.seller_name),value: val.seller_name,);
                        }).toList(),
                        value: selected_delivery_name,
                        hint: "اختار المندوب",
                        searchHint: "اختار المندوب",
                        onChanged: (value) {

                          setState(() {
                            selected_delivery_name = value;
                          });
                        },
                        isExpanded: true,
                      ),
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
                          child: Text('تحديد كل الاوردارات للمندوب المحدد',style: TextStyle(fontSize: 15,color: Colors.black),),
                          onPressed: (){
                              send_all_orders_havenot_delivery_id();
                          },
                        ),
                        SizedBox(width: 10,),
                        Icon(Icons.menu,color: Colors.black,size: 30),

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
                  decoration: InputDecoration(hintText: 'تليفون العميل',
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
                      for(int i=0;i<all_orders.length;i++){
                        if(all_orders[i].cust_phone.contains(value)){
                          search_orders.add(all_orders[i]);
                        }
                      }
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
                                search_orders[index].cust_city, search_orders[index].delivery_fee_plus) ,
                            onTap: (){
                              show_accept_send_order_to_delivery(index);
                            },
                          );
                    })

                ),

              ],
            ),
          ),
        )
    );
    
  }

  Widget Row_style(index,cust_name,cust_phone,cust_address,cust_note,cust_price,String cust_city,delivery_fee_plus){

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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ana 3aref anha re5ma gedaaan bs m3l4 wa7da wa7da
                //delivery_name_list feha object shayel delivery_name as(seller_name) , delivery_id as(seller_id)
                // search_orders feh object shayel kol tfasel el order
                // wana msh m3aya m3loma 8er el delivery_id bs
                // ana b7awel hna en ageb el delivery_name bm3lomiat el delivery_id
                // 1- bgeb el  delivery_id from search orders  /*search_orders[index].delivery_id*/
                //2-  bgeb el index el fe delivery_name_list el be7kk en delivery_id from search orders = delivery_id from delivery_name_list
                //temp_index = delivery_name_list.indexWhere((element) => element.seller_id == search_orders[index].delivery_id)
                //3- b3d ma asb7 m3aya el index bta3 el delivery_id bgeb el delivery_name (arg3 l 2 line want tfhm )
                //delivery_name_list[delivery_name_list.indexWhere((element) => element.seller_id == search_orders[index].delivery_id)].seller_name
                Text(temp_index!= -1? delivery_name_list[temp_index].seller_name:"",style: TextStyle(fontSize: 20,color: Colors.black),),
                SizedBox(width: 10,),
                Icon(Icons.directions_car,color: Colors.black,size: 30,)
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

  get_orders(){
    setState(() {
      controller_cust_phone.text="";
      all_orders.clear();
      search_orders.clear();
    });
    Query ref =FirebaseFirestore.instance.collection('companies').doc(comp_id).collection('waiting_orders')
        .where('cust_city',isEqualTo: city_selected);
    ref = ref.where('delivery_id',isEqualTo:'');
    ref.get().then((snapshot){
          if(snapshot.docs.isEmpty){
            setState(() {
              download_orders=false;
            });
          }
          snapshot.docs.forEach((element) {
            order Order = order(element.data()['cust_name'],element.data()['cust_phone'], element.data()['cust_city'],
            element.data()['cust_address'], element.data()['cust_price'], element.data()['cust_note'],
            element.data()['delivery_id'], element.data()['seller_id'],element.id,element.data()['delivery_fee_plus']);

            setState(() {
              all_orders.add(Order);
              search_orders.add(Order);
              download_orders=false;
              orders_count = search_orders.length;
            });

          });
    });
  }

  show_accept_send_order_to_delivery(int index){

    if(selected_delivery_name!=null) {
      showDialog(
          context: context,
          builder: (context) {
            bool waiting = false;
            return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: Text('تحديد المندوب'),
                    content: Center(
                      child: Column(
                        children: [
                          Text('هل تريد ارسال الاوردر المحدد الى المندوب',
                            style: TextStyle(
                                color: Colors.black, fontSize: 20),),
                          Text("؟" + selected_delivery_name, style: TextStyle(color: Colors.black, fontSize: 20),),
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
                            search_orders[index].delivery_id = delivery_name_list[delivery_name_list.indexWhere((element) => element.seller_name ==selected_delivery_name )].seller_id ;
                            FirebaseFirestore.instance.collection('companies').doc(comp_id).collection('waiting_orders')
                                .doc(search_orders[index].order_id).update(search_orders[index].to_map()).whenComplete(() {
                              // remove order from (search,all)_order_list and update ui
                                  all_orders.removeWhere((element) => element.delivery_id == search_orders[index].delivery_id&&
                                                         element.seller_id == search_orders[index].seller_id&&
                                                         element.cust_phone == search_orders[index].cust_phone);
                                  search_orders.removeAt(index);
                                  update_ui();
                                  Navigator.pop(context);
                            });
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

  update_ui(){
    setState(() {
      search_orders = search_orders;
      orders_count = search_orders.length;
    });
  }


  send_all_orders_havenot_delivery_id(){

    if(selected_delivery_name!= null){
      showDialog(
          context: context,
          builder: (context) {
            bool waiting = false;
            return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: Text('تحديد المندوب'),
                    content: Center(
                      child: Column(
                        children: [
                          Text('هل تريد ارسال كل الاوردارات التى لا تحتوى على مندوب الى المندوب المحدد',
                            style: TextStyle(
                                color: Colors.black, fontSize: 20),),
                          Text("؟" + selected_delivery_name, style: TextStyle(color: Colors.black, fontSize: 20),),
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
                            search_orders.clear();
                            if(all_orders.isNotEmpty) {
                              for (int i = 0; i < all_orders.length; i++) {
                                  all_orders[i].delivery_id = delivery_name_list[delivery_name_list.indexWhere((element) => element.seller_name == selected_delivery_name)].seller_id;
                                  FirebaseFirestore.instance.collection('companies').doc(comp_id).collection('waiting_orders')
                                      .doc(all_orders[i].order_id).update(all_orders[i].to_map()).whenComplete(() {
                                        if(i == all_orders.length-1){
                                          search_orders.clear();
                                          all_orders.clear();
                                          update_ui();
                                          Navigator.pop(context);
                                          waiting = false;
                                        }

                                  });

                              }
                            }else{
                              Navigator.pop(context);
                              Flushbar(
                                title: "ملاحظه",
                                message: "يجب اختيار محافظه او المحافظه فارغه",
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