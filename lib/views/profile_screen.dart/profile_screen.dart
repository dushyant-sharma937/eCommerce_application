import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emart_app/consts/consts.dart';
import 'package:emart_app/consts/lists.dart';
import 'package:emart_app/controllers/profile_controller.dart';
import 'package:emart_app/services/firebase_services.dart';
import 'package:emart_app/views/profile_screen.dart/components/details_card.dart';
import 'package:emart_app/views/splash_screen/splash_screen.dart';
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
  @override
  Widget build(BuildContext context) {
    var profileController = Get.put(ProfileController());
    final sp = context.watch<SignInProvider>();

    return bgWidget(
        child: Scaffold(
            body: StreamBuilder(
                stream: FirestoreServices.getUserData(currentUser!.uid),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(redColor)));
                  } else if (snapshot.data!.docs.isNotEmpty) {
                    var data = snapshot.data!.docs[0];
                    return SafeArea(
                        child: Column(children: [
                      //user details section
                      10.heightBox,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            data['imageUrl'] == ''
                                ? Image.asset(
                                    imgProfile2,
                                    width: 80,
                                    fit: BoxFit.cover,
                                  )
                                    .box
                                    .margin(const EdgeInsets.all(12))
                                    .roundedFull
                                    .clip(Clip.antiAlias)
                                    .make()
                                : Image.network(
                                    data['imageUrl'],
                                    width: 80,
                                    fit: BoxFit.cover,
                                  )
                                    .box
                                    .margin(const EdgeInsets.only(left: 12))
                                    .roundedFull
                                    .clip(Clip.antiAlias)
                                    .make(),
                            10.widthBox,
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                "${data['name']}"
                                    .text
                                    .fontFamily(bold)
                                    .white
                                    .size(18)
                                    .make(),
                                5.heightBox,
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
                      20.heightBox,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          detailsCard(
                            count: data['cart_count'],
                            title: "in your cart",
                            width: context.screenWidth / 3.4,
                          ),
                          detailsCard(
                            count: data['wishlist_count'],
                            title: "in your wishlist",
                            width: context.screenWidth / 3.4,
                          ),
                          detailsCard(
                            count: data['order_count'],
                            title: "your orders",
                            width: context.screenWidth / 3.4,
                          ),
                        ],
                      ),

                      // buttons section
                      ListView.separated(
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                              leading: Image.asset(
                                profileButtonIcon[index],
                                width: 22,
                                color: Colors.black87,
                              ),
                              title: profileButtonList[index]
                                  .text
                                  .fontFamily(semibold)
                                  .color(darkFontGrey)
                                  .make(),
                              onTap: index == 3
                                  ? () {
                                      profileController.nameController.text =
                                          data['name'];
                                      profileController.emailController.text =
                                          data['email'];
                                      Get.to(
                                          () => EditProfileScreen(data: data));
                                    }
                                  : index == 2
                                      ? () {
                                          // messages
                                        }
                                      : index == 1
                                          ? () {
                                              //my wishlist
                                            }
                                          : () {
                                              // my orders
                                            });
                        },
                        separatorBuilder: (context, index) {
                          return const Divider(color: lightGrey);
                        },
                        itemCount: profileButtonList.length,
                      )
                          .box
                          .white
                          .margin(const EdgeInsets.all(12))
                          .rounded
                          .padding(const EdgeInsets.symmetric(horizontal: 16))
                          .shadowSm
                          .make()
                          .box
                          .color(redColor)
                          .make(),
                    ]));
                  } else {
                    return const Center(
                      child: Text(
                          "No data available"), // Provide appropriate feedback
                    );
                  }
                })));
  }
}
