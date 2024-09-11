// import 'package:hive/hive.dart';
// import '../models/image_model.dart';
//
// abstract class ProductLocalDataSource {
//   void uploadLocalProducts({required List<ProductModel> products});
//   List<ProductModel> loadProducts();
// }
//
// class ProductLocalDataSourceImpl implements ProductLocalDataSource {
//   final Box box;
//
//   ProductLocalDataSourceImpl(this.box);
//
//   @override
//   List<ProductModel> loadProducts() {
//     List<ProductModel> products = [];
//     box.read(() {
//       for (int i = 0; i < box.length; i++) {
//         products.add(ProductModel.fromJson(box.get(i.toString())));
//       }
//     });
//     products.forEach((element){
//       print('this is element ${element.id}');
//     });
//     return products;
//   }
//
//   @override
//   void uploadLocalProducts({required List<ProductModel> products}) {
//     box.clear();
//      box.write(() {
//       for (int i = 0; i < products.length; i++) {
//         box.put(i.toString(), products[i].toJson());
//       }
//     });
//      box.read((){
//         print('this is box length ${box.length}');
//      });
//
//   }
// }
