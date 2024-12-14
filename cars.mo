import Nat32 "mo:base/Nat32";
import Trie "mo:base/Trie";
import Option "mo:base/Option";
import Text "mo:base/Text";

actor {
  public type Car = {
    make : Text;
    model : Text;
    title : Text;
    year : Nat32;
    km : Nat32;
    price : Nat32; 
    country : Text;
  };
  stable var counter = 0;
  public type carId = Nat32;
  private stable var next : carId = 0;
  private stable var cars : Trie.Trie<carId, Car> = Trie.empty();

  public func createCar(newCar : Car) : async Nat32 {
    let id = next;
    next += 1;
    cars := Trie.replace(
      cars,
      key(id),
      Nat32.equal,
      ?newCar
    ).0;
    counter += 1;
    return id;
  };

  public func getCar(id : carId) : async ?Car {
    let result = Trie.find(
      cars,
      key(id),
      Nat32.equal
    );
    return result;
  };

  public func updateCar(id : carId, newCar : Car) : async Bool {
    let result = Trie.find(
      cars,
      key(id),
      Nat32.equal
    );
    let exists = Option.isSome(result);

    if (exists) {
      cars := Trie.replace(
        cars,
        key(id),
        Nat32.equal,
        ?newCar
      ).0;
    };
    return exists;
  };

  public func delete(id : carId) : async Bool {
    let result = Trie.find(
      cars,
      key(id),
      Nat32.equal
    );
    let exists = Option.isSome(result);

    if (exists) {
      cars := Trie.replace(
        cars,
        key(id),
        Nat32.equal,
        null
      ).0;
    };
    counter -= 1;
    return exists;
  };

  public query func getAllCars() : async [(carId, Car)] {
    Trie.toArray<carId, Car, (carId, Car)>(
      cars,
      func(k : carId, v : Car) : (carId, Car) {(k, v)}
    )
  };
  
  public query func filterCarsByPriceRange(minPrice : Nat32, maxPrice : Nat32) : async [(carId, Car)] {
  Trie.toArray<carId, Car, (carId, Car)>(
    Trie.filter<carId, Car>(cars, func(_key : carId, car : Car) : Bool {
      car.price >= minPrice and car.price <= maxPrice
    }),
    func(k : carId, v : Car) : (carId, Car) {
      (k, v)
    }
  )
};

  public query func searchCarsByMake(make : Text) : async [(carId, Car)] {
  let filteredTrie = Trie.filter<carId, Car>(cars, func(_key : carId, car : Car) : Bool {
    car.make == make
  });

  Trie.toArray<carId, Car, (carId, Car)>(
    filteredTrie,
    func(k : carId, v : Car) : (carId, Car) {
      (k, v)
    }
  )
};

public query func getAveragePrice() : async ?Nat32 {
  let carArray = Trie.toArray<carId, Car, (carId, Car)>(
    cars,
    func(k : carId, v : Car) : (carId, Car) {
      (k, v)
    }
  );

  if (carArray.size() == 0) {
    return null;
  };

  var totalPrice : Nat32 = 0;

  for ((_, car) in carArray.vals()) {
    totalPrice += car.price;
  };
  let count = Nat32.fromNat(carArray.size());
  return ?(totalPrice / count);
};

public query func getCarCount() : async Nat {
    Trie.size(cars)
  };

  private func key(x : carId) : Trie.Key<carId> {{hash = x; key = x}}
}
