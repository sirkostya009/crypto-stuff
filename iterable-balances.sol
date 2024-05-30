// SPDX-License-Identifier: MIT 
pragma solidity >=0.5.0 <0.9.0;

struct IterableBalances {
    address[] keys;
    mapping(address => uint) values;
}

library Iterable {
    function get(IterableBalances storage self, address key) public view returns (uint) {
        return self.values[key];
    }

    function set(IterableBalances storage self, address key, uint value) public {
        if (self.values[key] == 0) {
            self.keys.push(key);
        }
        if (value == 0) {
            remove(self, key);
        } else {
            self.values[key] = value;
        }
    }

    function remove(IterableBalances storage self, address key) public {
        self.values[key] = 0;
        for (uint i = 0; i < self.keys.length; i++) {
            if (self.keys[i] == key) {
                self.keys[i] = self.keys[self.keys.length - 1];
                break;
            }
        }
    }

    function contains(IterableBalances storage self, address key) public view returns (bool) {
        return self.values[key] != 0;
    }

    function add(IterableBalances storage self, address key, uint amount) public {
        self.values[key] += amount;
    }
}
