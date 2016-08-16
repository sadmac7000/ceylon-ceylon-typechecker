Integer doThing({String|Integer+} stuff) {
    String|Integer a;
    if (is String s = stuff.first) {
        a = 1;
    } else {
        a = "One";
    }

    if (is Integer a) {
        print(a);
    }
}
