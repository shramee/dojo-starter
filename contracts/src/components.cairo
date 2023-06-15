use array::ArrayTrait;


#[derive(Component, Copy, Drop, Serde)]
struct Color {
    v: (u8, u8, u8), 
}

#[derive(Copy, Drop, Serde)]
struct Vec {
    x: u128,
    y: u128,
}

#[derive(Component, Copy, Drop, Serde)]
#[component(indexed = true)]
struct Physics {
    p: Vec,
    v: Vec,
    a: Vec,
}

fn new_physics(px: u128, py: u128, vx: u128, vy: u128, ax: u128, ay: u128) -> Physics {
    Physics { p: Vec { x: px, y: py,  }, v: Vec { x: vx, y: vy,  }, a: Vec { x: ax, y: ay,  },  }
}

fn zero_physics(px: u128, py: u128, vx: u128, vy: u128, ax: u128, ay: u128) -> Physics {
    new_physics(0, 0, 0, 0, 0, 0)
}
