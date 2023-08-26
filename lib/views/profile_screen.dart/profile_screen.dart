import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emart_app/consts/consts.dart';
import 'package:emart_app/consts/lists.dart';
import 'package:emart_app/controllers/profile_controller.dart';
import 'package:emart_app/services/firebase_services.dart';
import 'package:emart_app/views/chat_screen/messages_screen.dart';
import 'package:emart_app/views/orders_screen/orders_screen.dart';
import 'package:emart_app/views/splash_screen/splash_screen.dart';
import 'package:emart_app/views/wishlist_screen/wishlist_screen.dart';
import 'package:emart_app/widgets/bg_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../auth_screen/provider/sign_in_provider.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var profileController = Get.put(ProfileController());
  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SignInProvider>();

    return bgWidget(
      child: Scaffold(
        body: StreamBuilder(
            stream: FirestoreServices.getUserData(currentUser!.uid),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(redColor)));
              } else if (snapshot.data!.docs.isNotEmpty) {
                var data = snapshot.data!.docs[0];
                return SafeArea(
                    child: Column(children: [
                  //user details section
                  Dimensions.tenH.heightBox,
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: Dimensions.eightW),
                    child: Row(
                      children: [
                        data['imageUrl'] == ''
                            ? Image.asset(
                                imgProfile2,
                                width: Dimensions.hundredW * 0.8,
                                fit: BoxFit.cover,
                              )
                                .box
                                .margin(EdgeInsets.only(
                                    left: Dimensions.twelveW,
                                    right: Dimensions.twoW))
                                .roundedFull
                                .clip(Clip.antiAlias)
                                .make()
                            : Image.network(
                                data['imageUrl'],
                                width: Dimensions.hundredW * 0.8,
                                fit: BoxFit.cover,
                              )
                                .box
                                .margin(EdgeInsets.only(
                                    left: Dimensions.twelveW,
                                    right: Dimensions.twoW))
                                .roundedFull
                                .clip(Clip.antiAlias)
                                .make(),
                        Dimensions.tenW.widthBox,
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            "${data['name']}"
                                .text
                                .fontFamily(bold)
                                .white
                                .size(Dimensions.font18)
                                .make(),
                            (Dimensions.tenH * 0.5).heightBox,
                            "${data['email']}"
                                .text
                                .white
                                .fontFamily(semibold)
                                .make(),
                          ],
                        )),
                        OutlinedButton(
                            style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                              color: whiteColor,
                            )),
                            onPressed: () async {
                              sp.userSignOut();
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SplashScreen()));
                            },
                            child: "Log out"
                                .text
                                .fontFamily(semibold)
                                .white
                                .make()),
                      ],
                    ),
                  ),
                  Dimensions.twentyH.heightBox,

                  // FutureBuilder(
                  //     future: FirestoreServices.getCount(),
                  //     builder: (BuildContext context, AsyncSnapshot snapshot) {
                  //       if (!snapshot.hasData) {
                  //         return const Center(
                  //           child: LoadingIndicator(),
                  //         );
                  //       } else {
                  //         var dataCount = snapshot.data;
                  //         return Row(
                  //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //           children: [
                  //             detailsCard(
                  //               count: dataCount[0].toString(),
                  //               title: "in your cart",
                  //               width: context.screenWidth / 3.4,
                  //             ),
                  //             detailsCard(
                  //               count: dataCount[1].toString(),
                  //               title: "in your wishlist",
                  //               width: context.screenWidth / 3.4,
                  //             ),
                  //             detailsCard(
                  //               count: dataCount[2].toString(),
                  //               title: "your orders",
                  //               width: context.screenWidth / 3.4,
                  //             ),
                  //           ],
                  //         );
                  //       }
                  //     }),

                  // buttons section
                  ListView.separated(
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        leading: Image.asset(
                          profileButtonIcon[index],
                          width: Dimensions.tenW * 2.2,
                          color: Colors.black87,
                        ),
                        title: profileButtonList[index]
                            .text
                            .fontFamily(semibold)
                            .color(darkFontGrey)
                            .make(),
                        onTap: () {
                          switch (index) {
                            case 0:
                              Get.to(() => const OrderScreen());
                              break;
                            case 1:
                              Get.to(() => const WishlistScreen());
                              break;
                            case 2:
                              Get.to(() => const MessagesScreen());
                              break;
                            case 3:
                              profileController.nameController.text =
                                  data['name'];
                              profileController.emailController.text =
                                  data['email'];
                              Get.to(() => EditProfileScreen(data: data));
                              break;
                          }
                        },
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Divider(color: lightGrey);
                    },
                    itemCount: profileButtonList.length,
                  )
                      .box
                      .white
                      .margin(EdgeInsets.all(Dimensions.twelveW))
                      .rounded
                      .padding(
                          EdgeInsets.symmetric(horizontal: Dimensions.sixteenW))
                      .shadowSm
                      .make()
                      .box
                      .color(redColor.withOpacity(0.1))
                      .make(),
                ]));
              } else {
                return const Center(
                  child:
                      Text("No data available"), // Provide appropriate feedback
                );
              }
            }),
      ),
    );
  }
}
