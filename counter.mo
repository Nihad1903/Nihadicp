actor {
  stable var counter : Nat = 0;

  public func increment() : async Nat {
    counter += 1;
    return counter;
  };

  public func decrement() : async Nat{
    if(counter != 0){
      counter -= 1;
    };
    return counter;
  };

  public func showCounter() : async Nat{
    return counter;
  };

  public func setZero() : async Nat{
    counter := 0;
    return counter;
  };

  public func addValue(value: Nat) : async Nat{
    counter += value;
    return counter;
  };

};
