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
    isActive : Bool; 
  };
  stable var counter = 0;
  public type carId = Nat32;
  private stable var next : carId = 0;
  private stable var cars : Trie.Trie<carId, Car> = Trie.empty();

  public func createCar(newCar : Car) : async ?Nat32 {
  let carWithStatus : Car = {
    make = newCar.make;
    model = newCar.model;
    title = newCar.title;
    year = newCar.year;
    km = newCar.km;
    price = newCar.price;
    country = newCar.country;
    isActive = true; // Set isActive to true
  };

  let id = next;
  next += 1;
  cars := Trie.replace(
    cars,
    key(id),
    Nat32.equal,
    ?carWithStatus
  ).0;
  counter += 1;
  return ?id;
};

  public query func getPriceStatistics() : async ?{
  total : Nat32;
  average : Nat32;
  min : Nat32;
  max : Nat32;
} {
  let carArray = Trie.toArray<carId, Car, (carId, Car)>(
    cars,
    func(k : carId, v : Car) : (carId, Car) {(k, v)}
  );

  if (carArray.size() == 0) {
    return null;
  };

  var totalPrice : Nat32 = 0;
  var minPrice : Nat32 = 4294967295; 
  var maxPrice : Nat32 = 0;          

  for ((_, car) in carArray.vals()) {
    totalPrice += car.price;
    if (car.price < minPrice) {
      minPrice := car.price;
    };
    if (car.price > maxPrice) {
      maxPrice := car.price;
    };
  };

  let averagePrice = totalPrice / Nat32.fromNat(carArray.size());

  return ?{
    total = totalPrice;
    average = averagePrice;
    min = minPrice;
    max = maxPrice;
  };
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

  public query func filterCarsByYearRange(minYear : Nat32, maxYear : Nat32) : async [(carId, Car)] {
  Trie.toArray<carId, Car, (carId, Car)>(
    Trie.filter<carId, Car>(cars, func(_key : carId, car : Car) : Bool {
      car.year >= minYear and car.year <= maxYear
    }),
    func(k : carId, v : Car) : (carId, Car) {
      (k, v)
    }
  )
};

public query func getCarsByCountry(country: Text): async [(carId, Car)] {
  Trie.toArray<carId, Car, (carId, Car)>(
    Trie.filter<carId, Car>(cars, func(_key: carId, car: Car): Bool {
      car.country == country
    }),
    func(k: carId, v: Car): (carId, Car) {
      (k, v)
    }
  )
};
public query func filterCars(make : ?Text, minYear : ?Nat32, maxYear : ?Nat32, minPrice : ?Nat32, maxPrice : ?Nat32) : async [(carId, Car)] {
  Trie.toArray<carId, Car, (carId, Car)>(
    Trie.filter(cars, func(_key : carId, car : Car) : Bool {
      let makeMatch = switch (make) {
        case (?m) { car.make == m };
        case null { true };
      };
      let yearMatch = switch (minYear, maxYear) {
        case (?min, ?max) { car.year >= min and car.year <= max };
        case (?min, null) { car.year >= min };
        case (null, ?max) { car.year <= max };
        case (null, null) { true };
      };
      let priceMatch = switch (minPrice, maxPrice) {
        case (?min, ?max) { car.price >= min and car.price <= max };
        case (?min, null) { car.price >= min };
        case (null, ?max) { car.price <= max };
        case (null, null) { true };
      };
      car.isActive and makeMatch and yearMatch and priceMatch
    }),
    func(k : carId, v : Car) : (carId, Car) { (k, v) }
  )
};

  public query func searchCarsByTitle(title: Text): async [(carId, Car)] {
  let lowerCaseTitle = Text.toLowercase(title);

  Trie.toArray<carId, Car, (carId, Car)>(
    Trie.filter<carId, Car>(cars, func(_key: carId, car: Car): Bool {
      Text.toLowercase(car.title) == lowerCaseTitle
    }),
    func(k: carId, v: Car): (carId, Car) {
      (k, v)
    }
  )
};

public query func getCarCount() : async Nat {
    Trie.size(cars)
  };

  private func key(x : carId) : Trie.Key<carId> {{hash = x; key = x}}
};
