library corsac_startd.lists;

/// Create a single-element fixed-length list.
List list1(v1) => new List(1)..[0] = v1;

/// Create a two-element fixed-length list.
List list2(v1, v2) => new List(2)
  ..[0] = v1
  ..[1] = v2;

/// Create a three-element fixed-length list.
List list3(v1, v2, v3) => new List(3)
  ..[0] = v1
  ..[1] = v2
  ..[2] = v3;

/// Create a four-element fixed-length list.
List list4(v1, v2, v3, v4) => new List(4)
  ..[0] = v1
  ..[1] = v2
  ..[2] = v3
  ..[3] = v4;
