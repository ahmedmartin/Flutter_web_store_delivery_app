import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'classies/order.dart';
import 'home.dart';
import 'package:firebase_db_web_unofficial/firebasedbwebunofficial.dart';
import 'classies/city_country.dart';


class Add_orders extends StatefulWidget{
  
  String seller_id = '';
  List<order> seller_name_list = [];
  Add_orders(this.seller_id,this.seller_name_list);

  @override
  State<StatefulWidget> createState() {
    return _Add_orders(seller_id,seller_name_list);
  }

}

class _Add_orders extends State<Add_orders>{

  String seller_id ='';
  List<order> seller_name_list = [];
  _Add_orders(this.seller_id,this.seller_name_list);


  List<order> order_list = [];
  List<String> country =[];
  List<String> city = city_country().city;
  Map<String,List<String>> country_map = city_country().country_map;
  String selectedseller = "" ;
  String city_selected ;
  String country_selected;
  String comp_id = 'comp_id';
   // index for orders list that haven't all information (بيشاور على رقم الاوردر اللى البيانات فيه ناقصه)
  bool upload = false; // for circularprogress  show or hide
  TextEditingController controller_cust_name = TextEditingController();
  TextEditingController controller_cust_phone = TextEditingController();
  TextEditingController controller_cust_address = TextEditingController();
  TextEditingController controller_cust_price = TextEditingController();
  TextEditingController controller_cust_note = TextEditingController();
  TextEditingController controller_delivery_fee_plus = TextEditingController();

   @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: ()async{Navigator.push(context,MaterialPageRoute(builder: (context)=> Home()));},
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Draw_form(),
                Container(
                  height: 400,
                  child: ListView.builder(
                      itemCount: order_list.length,
                      itemBuilder: (context,index){
                        return Row_style(index,order_list[index].cust_name, order_list[index].cust_phone,
                            order_list[index].cust_address, order_list[index].cust_note, order_list[index].cust_price,
                            order_list[index].cust_city,order_list[index].delivery_fee_plus);
                      }),
                ),

               upload? CircularProgressIndicator(): Container(),

                SizedBox(height: 30,),
                RaisedButton(
                    child: Text('ارسال الاوردارات للتنفيذ',style: TextStyle(color: Colors.white,fontSize: 30),textAlign: TextAlign.center,),
                    color: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                        side: BorderSide(color: Colors.black)
                    ),
                    onPressed: (){
                      upload_orders();
                    }),
              ],
            ),
          ),
        )
    );
  }


  Widget Row_style(index,cust_name,cust_phone,cust_address,cust_note,cust_price,String cust_city,delivery_fee_plus){

    if(cust_city==null)
      cust_city="";

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 8,
      shadowColor: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
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




            //-----------------------------------------------------------------------------------------

            Container(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // button fro update row from list view
                RaisedButton(
                    child: Icon(Icons.update,color: Colors.white,size: 40,),
                    color: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                        side: BorderSide(color: Colors.black)
                    ),
                    onPressed: (){

                      setState(() {
                        controller_cust_name.text = cust_name;
                        controller_cust_phone.text = cust_phone;
                        controller_cust_address.text= cust_address;
                        controller_cust_note.text = cust_note;
                        controller_cust_price.text = cust_price;
                        if(cust_city.isNotEmpty)
                            city_selected = cust_city;
                        else
                            city_selected = null;

                        order_list.removeAt(index);
                      });

                    }),
                // button for delete row from list view
                RaisedButton(
                    child: Icon(Icons.delete_forever,color: Colors.white,size: 40,),
                    color: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                        side: BorderSide(color: Colors.black)
                    ),
                    onPressed: (){
                      setState(() {
                        order_list.removeAt(index);
                      });
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool correct_number = false;
  Widget Draw_form(){

    return Card(
      child: Padding(
        padding: EdgeInsets.all(30.0),
        child: Form(
          child: Column(
            children: [
              SizedBox(height: 20,),

              SearchableDropdown.single(
                items: seller_name_list.map((val){
                  return DropdownMenuItem(child: Text(val.seller_name),value: val.seller_name,);
                }).toList(),
                value: selectedseller,
                hint: "اختار التاجر",
                searchHint: "اختار التاجر",
                onChanged: (value) {
                  setState(() {
                    if(order_list.isEmpty) {
                      selectedseller = value;
                      seller_id = seller_name_list[seller_name_list.indexWhere((item) => item.seller_name ==selectedseller )].seller_id;
                    } else {
                     Flushbar(
                        title:  "ملاحظه",
                        message:  "يجب ارسال اوردارات التاجر الحالى قبل اختيار تاجر جديد",
                        duration:  Duration(seconds: 3),
                      )..show(context);
                    }
                  });
                },
                isExpanded: true,
              ),




              //---------------------------------------------------------------

              SizedBox(height: 20,),
              TextFormField(
                decoration: InputDecoration(hintText: 'اسم العميل...',
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                ),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black,fontSize: 20),

                controller: controller_cust_name,
              ),

              //-------------------------------------------------------------

              SizedBox(height: 20,),
              TextFormField(
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(hintText: 'التليفون',
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                ),
                textAlign: TextAlign.center,
                style: TextStyle(color: correct_number? Colors.black:Colors.red,fontSize: 20),
                controller: controller_cust_phone,
                onChanged: (val){
                    setState(() {
                      if(val.length==11)
                          correct_number =true;
                      else
                        correct_number = false;
                    });
                },
              ),

              //-----------------------------------------------------------------------

              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    child: DropdownButton(
                        hint: Text("اختار المركز"),
                        items: country.map((val){
                          return DropdownMenuItem(child: Text(val),value: val,);
                        }).toList(),
                        value: country_selected,
                        onChanged: (val){
                          setState(() {
                            country_selected = val;
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
                            country_selected = null;
                            country = country_map[val];
                            city_selected = val;
                          });
                        }),
                  ),
                ],
              ),

              //-----------------------------------------------------------------------

              SizedBox(height: 20,),
              TextFormField(
                decoration: InputDecoration(hintText: 'العنوان (اختيارى)',
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                ),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black,fontSize: 20),
                controller: controller_cust_address,
              ),

              //------------------------------------------------------------------------------

              SizedBox(height: 20,),
              TextFormField(
                decoration: InputDecoration(hintText: ' المبلغ الاجمالى',
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                ),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black,fontSize: 20),
                controller: controller_cust_price,
              ),

              //------------------------------------------------------------------------------------

              SizedBox(height: 20,),
              TextFormField(
                decoration: InputDecoration(hintText: 'زياده فى الشحن (اختيارى)',
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                ),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black,fontSize: 20),
                controller: controller_delivery_fee_plus,
              ),

              SizedBox(height: 20,),
              TextFormField(
                decoration: InputDecoration(hintText: 'ملاحظات (اختيارى)',
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                ),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black,fontSize: 20),
                controller: controller_cust_note,
              ),

              //-----------------------------------------------------------------------------------------

              SizedBox(height: 30,),
              RaisedButton(
                  child: Text('اضف الاوردر', style: TextStyle(fontSize: 35,color: Colors.white),textAlign: TextAlign.center,),
                  color: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.black)
                  ),
                  onPressed: (){

                      if(Check_no_empty(controller_cust_name.text, controller_cust_phone.text,
                          controller_cust_price.text,city_selected,selectedseller)){

                        setState(() {
                         if(country_selected!=null)
                            controller_cust_address.text += ' ' + country_selected + ' ';

                         order_list.add(order.new_order(controller_cust_name.text, controller_cust_phone.text,city_selected,
                             controller_cust_address.text, controller_cust_price.text, controller_cust_note.text,
                             seller_id,controller_delivery_fee_plus.text));

                         controller_cust_name.text = "";
                         controller_cust_phone.text = "";
                         controller_cust_address.text= "";
                         controller_cust_note.text = "";
                         controller_cust_price.text = "";
                         controller_delivery_fee_plus.text ="";
                         country_selected = null;
                         country.clear();
                         city_selected = null;
                       });
                     }
                  }),
            ],
          ),

        ),
      ),
    ) ;
  }

  // ------ uploads all orders to waiting_orders and remove from request_orders
  upload_orders(){

    setState(() {
      upload = true;
    });
    DatabaseRef ref = FirebaseDatabaseWeb.instance.reference().child('companies').child(comp_id)
        .child('requested_orders').child(seller_id);
        ref.child('count').once().then((snapshot){
          if(snapshot.value != null) {
            if (int.parse(snapshot.value) > order_list.length) {
              ref.child('count').set(
                  (int.parse(snapshot.value) - order_list.length).toString());
            } else if (int.parse(snapshot.value) == order_list.length) {
              ref.remove();
            } else {
              Flushbar(
                title: "ملاحظه",
                message: "عدد الاوردارات المسجله اكبر من العدد المستلم (تاكد من الاوردارات)",
                duration: Duration(seconds: 5),
              )
                ..show(context);
              setState(() {
                upload = false;
              });
            }
          }
        }).whenComplete((){
          if(upload) {
            for (int i = 0; i < order_list.length; i++) {
              FirebaseFirestore.instance.collection('companies').doc(comp_id).collection('waiting_orders')
                  .add(order_list[i].to_map()).whenComplete(() {
                    if (i == order_list.length - 1) {
                      setState(() {
                        order_list.clear();
                        order_list = [];
                        upload = false;
                      });
                    }
                  });
            }
          }
        });
  }

  bool Check_no_empty(String cust_name,String cust_phone,String cust_price,String cust_city,String seller){

    if(seller.isEmpty){
        Flushbar(
        title: "ملاحظه",
        message: "يجب اختيار التاجر",
        duration: Duration(seconds: 3),
        )..show(context);
        return false;
    }else if(cust_name.isEmpty){
        Flushbar(
        title:  "ملاحظه",
        message:  "يجب كتابة اسم العميل",
        duration:  Duration(seconds: 3),
        )..show(context);
        return false;
    }else if (cust_phone.isEmpty || cust_phone.length != 11){
        Flushbar(
        title:  "ملاحظه",
        message:  "يجب كتابة تليفون العميل و مكون من 11 رقم",
        duration:  Duration(seconds: 3),
        )..show(context);
        return false;
    }else if(cust_city == null) {
      Flushbar(
        title: "ملاحظه",
        message: "يجب اختيار محافظة العميل",
        duration: Duration(seconds: 3),
      )
        ..show(context);
      return false;
    }else if(cust_price.isEmpty){
      Flushbar(
        title:  "ملاحظه",
        message:  "يجب كتابة مبلغ اجمالى الاوردر",
        duration:  Duration(seconds: 3),
      )..show(context);
      return false;

    }else if (country_selected == null && country.isNotEmpty) {
      print(country.isNotEmpty);
      Flushbar(
        title: "ملاحظه",
        message: "يجب اختيار المركز المناسب للمحافظه",
        duration: Duration(seconds: 3),
      )..show(context);
        return false;
      }else
        return true;
      

  }


}