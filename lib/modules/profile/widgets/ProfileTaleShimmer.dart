import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProfileTaleShimmer extends StatelessWidget {
  const ProfileTaleShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 171,
              color: Colors.grey,
            ),
          ),
          SizedBox(width: 1,),
          Expanded(
            child: Container(
              height: 171,
              color: Colors.grey,
            ),
          ),
          SizedBox(width: 1,),
          Expanded(
            child: Container(
              height: 171,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
