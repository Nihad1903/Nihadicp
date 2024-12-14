import Nat32 "mo:base/Nat32";
import Trie "mo:base/Trie";
import Option "mo:base/Option";
import List "mo:base/List";
import Text "mo:base/Text";
import Result "mo:base/Result";

actor {

  public type SuperHero  = {
    name: Text;
    superPowers: List.List<Text>;
  };
  
  public type superHeroId = Nat32;

  private stable var next : superHeroId = 0;
  private stable var superHeroes : Trie.Trie<superHeroId, SuperHero> = Trie.empty();


  public func createHero(newHero : SuperHero) : async Nat32{

    let id = next;
    next += 1;
    superHeroes := Trie.replace(
    superHeroes,
    key(id),
    Nat32.equal,
    ?newHero
    ).0;
    return id;
  };

  public func getHero(id: superHeroId) : async ?SuperHero{
    let result = Trie.find(
      superHeroes,
      key(id),
      Nat32.equal,
    );
    return result;
  };

  public func updateHero(id: superHeroId, newHero: SuperHero) : async Bool{
    let result = Trie.find(
      superHeroes,
      key(id),
      Nat32.equal,
    );
    let exists = Option.isSome(result);
    
    if(exists){
      superHeroes := Trie.replace(
        superHeroes,
        key(id),
        Nat32.equal,
        ?newHero
      ).0;
    };
    return exists;
  };

  public func delete(id: superHeroId) : async Bool{
    let result = Trie.find(
      superHeroes,
      key(id),
      Nat32.equal,
    );
    let exists = Option.isSome(result);
    
    if(exists){
      superHeroes := Trie.replace(
        superHeroes,
        key(id),
        Nat32.equal,
        null
      ).0;
    };
    return exists;
  };

  private func key(x: superHeroId) : Trie.Key<superHeroId>{
    {hash = x; key = x};
  };
}
