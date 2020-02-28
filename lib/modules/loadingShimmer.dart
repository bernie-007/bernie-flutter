import 'package:flutter/material.dart';
import 'package:matching_tantan_app/models/color_model.dart';
import 'package:shimmer/shimmer.dart';

double width;
double height;

class LoadingShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Expanded(
      child: Container(
        width: width,
        height: height * 0.7,
        decoration: BoxDecoration(
          color: Colors.blueGrey[400],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0)
          ),
        ),
        child: Column(
          children: <Widget>[
            // superlike loading effect with shimmer
            Container(
              height: height * 0.16,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.03),
                    child: Shimmer.fromColors(
                      highlightColor: myColor.blueColorLight,
                      baseColor: myColor.blueColorDark,
                      period: Duration(milliseconds: 1500),
                      child: ShimmerHorizontalLayout(),
                    ),
                  );
                },
              ),
            ),
            // recent chat loading effect with shimmer
            Container(
              child: Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: myColor.primaryColorLight,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0)
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0)
                    ),
                    child: ListView.builder(
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: height * 0.03),
                          child: Shimmer.fromColors(
                            highlightColor: myColor.blueColorLight,
                            baseColor: myColor.blueColorDark,
                            period: Duration(milliseconds: 1500),
                            child: ShimmerVerticalLayout(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerHorizontalLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: height * 0.01),
      child: Column(
        children: <Widget>[
          Container(
            height: height * 0.06,
            width: width * 0.12,
            decoration: BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle
            ),
          ),
          SizedBox(height: height * 0.01,),
          Container(
            height: height * 0.02,
            width: width * 0.08,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}

class ShimmerVerticalLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            height: height * 0.072,
            width: width * 0.13,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: height * 0.02,
                width: width * 0.33,
                color: Colors.grey,
              ),
              SizedBox(height: height * 0.01,),
              Container(
                height: height * 0.02,
                width: width * 0.63,
                color: Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }
}