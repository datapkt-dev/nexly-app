import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SearchPageShimmer extends StatelessWidget {
  const SearchPageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: Row(
              children: [
                Container(
                  height: 16,
                  width: 120,
                  color: Colors.grey,
                ),
                const Spacer(),
                const Icon(Icons.keyboard_arrow_right),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                width: 125,
                height: 125,
                decoration: ShapeDecoration(
                  color: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(width: 4,),
              Container(
                width: 125,
                height: 125,
                decoration: ShapeDecoration(
                  color: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
