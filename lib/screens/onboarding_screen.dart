import 'package:attendancex/screens/category_login.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);
  static const routeName = '/onboardingScreen';
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  Widget buidPage({
    required String imageUrl,
    required String title,
    required Color backcolor,
    required String subTitle,
  }) =>
      Container(
        color: backcolor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                decoration: const BoxDecoration(
                    borderRadius:
                        BorderRadius.only(bottomRight: Radius.circular(700))),
                height: MediaQuery.of(context).size.height * 0.65,
                child: Image.asset(imageUrl,
                    fit: BoxFit.cover,
                    height: MediaQuery.of(context).size.height * 0.4,
                    width: double.infinity)),
            const SizedBox(
              height: 50,
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 25),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              subTitle,
              style: const TextStyle(fontSize: 15),
            )
          ],
        ),
      );

  final controller = PageController();
  bool isLastPage = false;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(bottom: 80),
        child: PageView(
            controller: controller,
            onPageChanged: (index) {
              setState(() => isLastPage = index == 2);
            },
            children: [
              buidPage(
                  imageUrl: 'lib/assets/images/attendance.png',
                  title: 'Fast and Secured',
                  backcolor: Colors.blue.shade600,
                  subTitle: 'E-rollCall provides easy way to take attendance'),
              buidPage(
                  imageUrl: 'lib/assets/images/secondpage.png',
                  title: 'Just a click',
                  backcolor: const Color.fromARGB(255, 203, 204, 206),
                  subTitle: 'Just a click no stress to check in'),
              buidPage(
                  imageUrl: 'lib/assets/images/thirdpage.jpg',
                  title: 'Easy and Fast',
                  backcolor: Colors.white,
                  subTitle:
                      'E-rollCall provides easy way to take attendance and the fastest way'),
            ]),
      ),
      bottomSheet: isLastPage
          ? Container(
              color: Colors.teal.shade700,
              width: double.infinity,
              height: 80,
              child: Center(
                child: TextButton(
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      primary: Colors.white,
                      //   backgroundColor: Colors.teal.shade700,
                      maximumSize: const Size.fromHeight(80),
                    ),
                    onPressed: () async {
                      Navigator.of(context)
                          .pushNamed(CategoryLoginScreen.routeName);
                    },
                    child: const Text(
                      'Get Started',
                      style: TextStyle(fontSize: 24),
                    )),
              ),
            )
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => controller.jumpToPage(2),
                    child: const Text('SKIP'),
                  ),
                  Center(
                    child: SmoothPageIndicator(
                      controller: controller,
                      count: 3,
                      effect: WormEffect(
                          spacing: 16,
                          dotColor: Colors.teal.shade700,
                          activeDotColor: Colors.black87),
                      onDotClicked: (index) => controller.animateToPage(index,
                          duration: const Duration(microseconds: 500),
                          curve: Curves.easeIn),
                    ),
                  ),
                  TextButton(
                      onPressed: () => controller.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          ),
                      child: const Text('NEXT'))
                ],
              ),
            ),
    );
  }
}
