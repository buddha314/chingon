use Chingon,
    Charcoal;

class ChingonTest : UnitTest {
  proc init() {
    super.init();
  }

  proc run() {
    return 0;
  }
}

proc main(args: [] string) : int {
  var t = new ChingonTest();
  var ret = t.run();
  t.report();
  return ret;
}
