import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:vendor/screens/registor_screen/registor_screen.dart';
import 'package:vendor/widgets/custom_button.dart';

class TermsAndConditions extends StatefulWidget {
  const TermsAndConditions({super.key});

  @override
  State<TermsAndConditions> createState() => _TermsAndConditionsState();
}

class _TermsAndConditionsState extends State<TermsAndConditions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              PageTransition(
                  child: RegistorScreen(),
                  type: PageTransitionType.leftToRight));
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 37,
            width: 37,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/Group 79.png"))),
          ),
        ),
      )),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Terms & Condition",
                style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black)),
            Text(
              softWrap: true,
              textAlign: TextAlign.start,
              "Terms of service are the legal agreements between a service provider and a person who wants to use that service. The person must agree to abide by the terms of service in order to use the offered service. Terms of service can also be merely a disclaimer, especially regarding the use of websites.\nTerms of service are the legal agreements between a service in order to use the offered service. Terms of service can also be merely a disclaimer, especially regarding the use of websites.\nTerms of service are the legal agreements between a service provider and a person who wants The person must agree to abide by the terms of service in order to use the offered service. Terms of service can also be merely a disclaimer, especially regarding the use of websites.\nTerms of service are the legal agreements between a service provider and a persons of service in order to use the offered service. Terms of service can also be merely a disclaimer, especially regarding the use of websites.",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xff828282),
              ),
            ),
            const SizedBox(height: 100),
            CustomButton(
              height: 50,
              width: double.infinity,
              btnText: "I AGREE",
              bgc: const Color(0xffF05A28),
              onPress: () {
                bool userAgreed = true;
                Navigator.pop(context, userAgreed);
                // Navigator.push(
                //     context,
                //     PageTransition(
                //         child: RegistorScreen(),
                //         type: PageTransitionType.rightToLeft));
              },
            ),
          ],
        ),
      ),
    );
  }
}
