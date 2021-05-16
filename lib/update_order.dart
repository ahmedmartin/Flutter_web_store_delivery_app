import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'classies/city_country.dart';
import 'classies/order.dart';
import 'home.dart';




class Update_order extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _Update_order();
  }
}

class _Update_order extends State<Update_order>{

  TextEditingController controller_cust_phone = TextEditingController();
  List<order> order_list =[];
  String comp_id = 'comp_id';
  bool get_order = false;
  @override
  Widget build(BuildContext context) {

    return WillPopScope(
        onWillPop: ()async{Navigator.push(context,MaterialPageRoute(builder: (context)=> Home()));},
        child: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
          children: [

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
             if(value.length == 11){
                 setState(() {
                   get_order=true;
                   order_list.clear();
                 });
                 // get orders that it's phone number is equal value for update it
                  FirebaseFirestore.instance.collection('companies').doc(comp_id).collection('waiting_orders')
                  .where('cust_phone',isEqualTo: value ).get().then((snapshot){
                    if(snapshot.docs.isNotEmpty) {
                       snapshot.docs.forEach((element) {
                         order Order = order.update(element['cust_name'], element['cust_phone'], element['cust_city'], element['cust_address'],
                             element['cust_price'], element['cust_note'], element['seller_id'], element['delivery_fee_plus'],element.id);
                         setState(() {
                           order_list.add(Order);
                           get_order = false;
                         });
                       });
                     }else{
                       setState(() {
                         get_order = false;
                       });
                       Flushbar(
                         title:  "ملاحظه",
                         message:  "لا يوجد عميل بهذا الرقم",
                         duration:  Duration(seconds: 3),
                       )..show(context);
                     }
                   });
               }
             },
            ),

           SizedBox(height: 10,),
           get_order? CircularProgressIndicator():Container(),

           SizedBox(height: 20,),
            Flexible(
                child: ListView.builder(
                    itemCount: order_list.length,
                    itemBuilder: (context,index){
                      return GestureDetector(
                        child: Row_style(index,order_list[index].cust_name,order_list[index].cust_phone, order_list[index].cust_address,
                            order_list[index].cust_note, order_list[index].cust_price, order_list[index].cust_city, order_list[index].delivery_fee_plus),

                        onTap: (){
                            update_order(index);
                        },
                      );
                    }

            )),

            
       ],
      ),
     ),
    ));

  }

  Widget Row_style(index,cust_name,cust_phone,cust_address,cust_note,cust_price,String cust_city,delivery_fee_plus){

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
                FlatButton(
                  color: Colors.black.withOpacity(0),
                  child: Text("عرض بيانات التاجر",style: TextStyle(fontSize: 20,color: Colors.black),),
                  onPressed: (){
                      show_seller_info(index);
                },),
                Icon(Icons.remove_red_eye,color: Colors.black,size: 30,)
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

  List<String> city = city_country().city;
  String city_selected;
  TextEditingController controller_cust_name = TextEditingController();
  TextEditingController controller_cust_address = TextEditingController();
  TextEditingController controller_cust_price = TextEditingController();
  TextEditingController controller_cust_note = TextEditingController();
  TextEditingController controller_delivery_fee_plus = TextEditingController();
  update_order(int index){
    showDialog(
        context: context,
        builder: (context) {
      controller_cust_name.text = order_list[index].cust_name;
      controller_cust_address.text = order_list[index].cust_address;
      controller_cust_price.text =  order_list[index].cust_price;
      controller_cust_note.text = order_list[index].cust_note;
      controller_delivery_fee_plus.text = order_list[index].delivery_fee_plus;
      city_selected = order_list[index].cust_city;
      return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
                title: Text('تعديل البيانات'),
                content: Center(
                   child: Draw_form(),
                ),
                actions: [

                  FlatButton(
                      child: Text('تعديل الاوردر', style: TextStyle(fontSize: 30,color: Colors.white),textAlign: TextAlign.center,),
                      color: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: BorderSide(color: Colors.black)
                      ),
                      onPressed: (){

                        if(Check_no_empty(controller_cust_name.text, controller_cust_phone.text,

                            controller_cust_address.text, controller_cust_price.text,city_selected,order_list[index].seller_id)){
                            order_list[index].cust_name = controller_cust_name.text;
                            order_list[index].cust_phone = controller_cust_phone.text;
                            order_list[index].cust_city = city_selected;
                            order_list[index].cust_address = controller_cust_address.text;
                            order_list[index].cust_price = controller_cust_price.text;
                            order_list[index].delivery_fee_plus = controller_delivery_fee_plus.text;
                            order_list[index].cust_note = controller_cust_note.text;

                            FirebaseFirestore.instance.collection('companies').doc(comp_id).collection('waiting_orders')
                            .doc(order_list[index].order_id).update(order_list[index].to_map()).whenComplete((){
                              update_ui();


                            });
                        }
                      }),
                ],
            );
          });
    });
  }
  update_ui(){

    setState((){
      order_list = order_list;
      Navigator.pop(context);
    });
  }

  Widget Draw_form(){

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(30.0),
        child: Form(
          child: Column(
            children: [

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
                style: TextStyle(color: Colors.black,fontSize: 20),
                controller: controller_cust_phone,
              ),

              //-----------------------------------------------------------------------

              SizedBox(height: 20,),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 200,vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  border: Border.all(
                      color: Colors.black, style: BorderStyle.solid, width: 2),
                ),
                child: DropdownButton(
                    hint: Text("اختار المحافظه"),
                    items: city.map((val){
                      return DropdownMenuItem(child: Text(val),value: val,);
                    }).toList(),
                    value: city_selected,
                    onChanged: (val){
                      setState(() {
                        city_selected = val;
                      });
                    }),
              ),

              //-----------------------------------------------------------------------

              SizedBox(height: 20,),
              TextFormField(
                decoration: InputDecoration(hintText: 'العنوان',
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

            ],
          ),

        ),
      ),
    ) ;
  }

  bool Check_no_empty(String cust_name,String cust_phone,String cust_address,String cust_price,String cust_city,String seller){

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
    }else if (cust_phone.isEmpty){
      Flushbar(
        title:  "ملاحظه",
        message:  "يجب كتابة رقم العميل",
        duration:  Duration(seconds: 3),
      )..show(context);
      return false;
    }else if(cust_city == null){
      Flushbar(
        title:  "ملاحظه",
        message:  "يجب اختيار محافظة العميل",
        duration:  Duration(seconds: 3),
      )..show(context);
      return false;
    }else if (cust_address.isEmpty){
      Flushbar(
        title:  "ملاحظه",
        message:  "يجب كتابة عنوان العميل",
        duration:  Duration(seconds: 3),
      )..show(context);
      return false;
    }else if(cust_price.isEmpty){
      Flushbar(
        title:  "ملاحظه",
        message:  "يجب كتابة مبلغ اجمالى الاوردر",
        duration:  Duration(seconds: 3),
      )..show(context);
      return false;

    }else
      return true;
  }


  show_seller_info(int index){

    showDialog(
        context: context,
        builder: (context) {
          String seller_name="";
          String seller_phone="";
          return StatefulBuilder(
              builder: (context, setState) {
                FirebaseFirestore.instance.collection('sellers').doc(order_list[index].seller_id).get().then((snapshot){
                  setState((){
                    seller_name = snapshot.data()['name'];
                    seller_phone= snapshot.data()['phone'];
                  });
                });
                return AlertDialog(
                    title: Text('بيانات التاجر'),
                    content: Center(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person),
                              Text(seller_name, style: TextStyle(fontSize: 30,color: Colors.black),textAlign: TextAlign.center,),
                            ],
                          ),

                          Row(
                            children: [
                              Icon(Icons.phone),
                              Text(seller_phone, style: TextStyle(fontSize: 30,color: Colors.black),textAlign: TextAlign.center,),
                            ],
                          ),
                        ],
                      ),
                    ));
              });
        });

  }

}