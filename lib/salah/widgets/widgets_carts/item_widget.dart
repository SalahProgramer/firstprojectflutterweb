import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ItemWidget extends StatefulWidget {
  const ItemWidget({super.key});

  @override
  State<ItemWidget> createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  @override
  Widget build(BuildContext context) {
    return
    //   Container(
    //   height: 100.h,
    //   width: double.infinity,
    //   decoration: BoxDecoration(
    //       borderRadius: BorderRadius.circular(20.r),
    //       boxShadow: [
    //         BoxShadow(
    //           color: Colors.grey.withValues(alpha: 0.2),
    //           blurRadius: 5,
    //         ),
    //       ],
    //       color: Colors.white),
    //   child: Stack(
    //     alignment: Alignment.bottomLeft,
    //     children: [
    //       SizedBox(
    //         width: double.infinity,
    //         child: Row(
    //           children: [
    //             Container(
    //               width: 100,
    //               decoration: BoxDecoration(
    //                 borderRadius: BorderRadius.only(
    //                     topRight: Radius.circular(10),
    //                     topLeft: Radius.circular(10)),
    //               ),
    //               child: ClipRRect(
    //                 borderRadius: BorderRadius.circular(0),
    //                 child: FancyShimmerImage(
    //                   imageUrl: image,
    //                 ),
    //               ),
    //             ),
    //             Padding(
    //               padding:
    //               const EdgeInsets.only(top: 10, bottom: 10, right: 20),
    //               child: Column(
    //                 mainAxisAlignment: MainAxisAlignment.spaceAround,
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   SizedBox(
    //                     width: 250,
    //                     child: Text(
    //                       name.length > 50
    //                           ? '${name.substring(0, 50)}...'
    //                           : name,
    //                       style: TextStyle(
    //                           fontWeight: FontWeight.bold, fontSize: 16),
    //                     ),
    //                   ),
    //                   Row(
    //                     children: [
    //                       Text(
    //                         "الحجم : ",
    //                         style: TextStyle(
    //                           fontWeight: FontWeight.bold,
    //                           fontSize: 18,
    //                           color: mainColor,
    //                         ),
    //                       ),
    //                       Text(
    //                         type.toString(),
    //                         style: TextStyle(
    //                             fontWeight: FontWeight.bold, fontSize: 16),
    //                       ),
    //                     ],
    //                   ),
    //                   Visibility(
    //                     visible: item!.quantityExist > 1 ? true : false,
    //                     child: Row(
    //                       children: [
    //                         Text(
    //                           "الكمية : ",
    //                           style: TextStyle(
    //                             fontWeight: FontWeight.bold,
    //                             fontSize: 18,
    //                             color: mainColor,
    //                           ),
    //                         ),
    //                         SizedBox(
    //                           width: 5,
    //                         ),
    //                         Padding(
    //                           padding: const EdgeInsets.only(bottom: 5),
    //                           child: Row(
    //                             children: [
    //                               InkWell(
    //                                 onTap: () {
    //                                   if (item.quantity > 1) {
    //                                     int quantity = int.parse(
    //                                         item.quantity.toString());
    //                                     // Call the updateCartItem function in CartProvider
    //                                     cartProvider.updateCartItem(
    //                                       item.copyWith(
    //                                         quantity: quantity - 1,
    //                                       ),
    //                                     );
    //                                     setState(() {});
    //                                   }
    //                                 },
    //                                 child: Container(
    //                                   width: 27,
    //                                   height: 27,
    //                                   decoration: BoxDecoration(
    //                                     shape: BoxShape.circle,
    //                                     color: Colors.white,
    //                                     border: Border.all(
    //                                         color: Color.fromARGB(
    //                                             255, 75, 75, 75),
    //                                         width: 2),
    //                                   ),
    //                                   child: Center(
    //                                     child: Icon(
    //                                       Icons.remove,
    //                                       size: 22,
    //                                       color:
    //                                       Color.fromARGB(255, 61, 61, 61),
    //                                     ),
    //                                   ),
    //                                 ),
    //                               ),
    //                               SizedBox(
    //                                 width: 10,
    //                               ),
    //                               Text(
    //                                 "$qty",
    //                                 style: TextStyle(
    //                                     fontWeight: FontWeight.bold,
    //                                     fontSize: 16),
    //                               ),
    //                               SizedBox(
    //                                 width: 10,
    //                               ),
    //                               InkWell(
    //                                 onTap: () {
    //                                   int quantity =
    //                                   int.parse(item.quantity.toString());
    //                                   int quantityExist = int.parse(
    //                                       item.quantityExist.toString());
    //                                   if (quantity < quantityExist) {
    //                                     cartProvider.updateCartItem(
    //                                       item.copyWith(
    //                                         quantity: quantity + 1,
    //                                       ),
    //                                     );
    //                                     setState(() {});
    //                                   } else {
    //                                     Fluttertoast.showToast(
    //                                         msg: "لا يمكن اضافة المزيد");
    //                                   }
    //                                 },
    //                                 child: Container(
    //                                   width: 27,
    //                                   height: 27,
    //                                   decoration: BoxDecoration(
    //                                     shape: BoxShape.circle,
    //                                     color: Colors.white,
    //                                     border: Border.all(
    //                                         color: Color.fromARGB(
    //                                             255, 75, 75, 75),
    //                                         width: 2),
    //                                   ),
    //                                   child: Center(
    //                                     child: Icon(
    //                                       Icons.add,
    //                                       size: 20,
    //                                       color:
    //                                       Color.fromARGB(255, 61, 61, 61),
    //                                     ),
    //                                   ),
    //                                 ),
    //                               ),
    //                             ],
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //                   ),
    //                   Row(
    //                     children: [
    //                       Text(
    //                         "السعر : ",
    //                         style: TextStyle(
    //                           fontWeight: FontWeight.bold,
    //                           fontSize: 18,
    //                           color: mainColor,
    //                         ),
    //                       ),
    //                       Text(
    //                         "₪${(double.tryParse(price.toString())?.toInt() ?? 0)}",
    //                         style: TextStyle(
    //                           fontWeight: FontWeight.bold,
    //                           fontSize: 18,
    //                           color: Color.fromARGB(255, 124, 21, 138),
    //                         ),
    //                       ),
    //                     ],
    //                   )
    //                 ],
    //               ),
    //             )
    //           ],
    //         ),
    //       ),
    //       Padding(
    //         padding: const EdgeInsets.all(6.0),
    //         child: Text(
    //           "₪${(double.tryParse(price.toString())?.toInt() ?? 0) * qty}",
    //           style: TextStyle(
    //             fontWeight: FontWeight.bold,
    //             fontSize: 20,
    //             color: Colors.red,
    //           ),
    //         ),
    //       )
    //     ],
    //   ),
    // );
    SizedBox();
  }
}
