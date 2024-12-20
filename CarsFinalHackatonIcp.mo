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

  


  public query func getActiveCars() : async [(carId, Car)] {
    Trie.toArray<carId, Car, (carId, Car)>(
      Trie.filter(cars, func(_key : carId, car : Car) : Bool {
        car.isActive
      }),
      func(k : carId, v : Car) : (carId, Car) { (k, v) }
    )
  };

  public query func getInactiveCars() : async [(carId, Car)] {
    Trie.toArray<carId, Car, (carId, Car)>(
      Trie.filter(cars, func(_key : carId, car : Car) : Bool {
        not car.isActive
      }),
      func(k : carId, v : Car) : (carId, Car) { (k, v) }
    )
  };

  public func updateCarPartial(id : carId, partialUpdate : { make : ?Text; model : ?Text; title : ?Text; year : ?Nat32; km : ?Nat32; price : ?Nat32; country : ?Text; isActive : ?Bool }) : async Bool {
    let existingCar = Trie.find(cars, key(id), Nat32.equal);

    switch (existingCar) {
      case (?car) {
        let updatedCar : Car = {
          make = Option.get(partialUpdate.make, car.make);
          model = Option.get(partialUpdate.model, car.model);
          title = Option.get(partialUpdate.title, car.title);
          year = Option.get(partialUpdate.year, car.year);
          km = Option.get(partialUpdate.km, car.km);
          price = Option.get(partialUpdate.price, car.price);
          country = Option.get(partialUpdate.country, car.country);
          isActive = Option.get(partialUpdate.isActive, car.isActive);
        };

        cars := Trie.replace(cars, key(id), Nat32.equal, ?updatedCar).0;
        return true;
      };
      case null {
        return false;
      };
    };
  };

  public query func getActivePriceStatistics() : async ?{
    total : Nat32;
    average : Nat32;
    min : Nat32;
    max : Nat32;
  } {
    let carArray = Trie.toArray<carId, Car, (carId, Car)>(
      Trie.filter(cars, func(_key : carId, car : Car) : Bool {
        car.isActive
      }),
      func(k : carId, v : Car) : (carId, Car) { (k, v) }
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

  
  public func delete(id : carId) : async Bool {
    let existingCar = Trie.find(cars, key(id), Nat32.equal);

    switch (existingCar) {
      case (?car) {
        let updatedCar = { car with isActive = false };
        cars := Trie.replace(cars, key(id), Nat32.equal, ?updatedCar).0;
        counter -= 1;
        return true;
      };
      case null {
        return false;
      };
    };
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

  private stable var favorites: Trie.Trie<carId, Bool> = Trie.empty();

public func addFavorite(id: carId): async Bool {
  if (Trie.find(cars, key(id), Nat32.equal) != null) {
    favorites := Trie.replace(favorites, key(id), Nat32.equal, ?true).0;
    return true;
  };
  return false;
};

public query func getFavorites(): async [(carId, Car)] {
  Trie.toArray<carId, Car, (carId, Car)>(
    Trie.filter(cars, func(_key: carId, _car: Car): Bool {
      switch (Trie.find(favorites, key(_key), Nat32.equal)) {
        case (?true) { true };
        case _ { false };
      }
    }),
    func(k: carId, v: Car): (carId, Car) { (k, v) }
  )
};


  public func markCarAsSold(id: carId) : async Bool {
  let existingCar = Trie.find(cars, key(id), Nat32.equal);
  switch (existingCar) {
    case (?car) {
      let updatedCar = { car with isActive = false; isSold = true };
      cars := Trie.replace(cars, key(id), Nat32.equal, ?updatedCar).0;
      return true;
    };
    case null { return false; };
  }
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
