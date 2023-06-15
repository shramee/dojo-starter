#[system]
mod Spawn {
    use array::ArrayTrait;
    use traits::Into;

    use dojo_autonomous_agents::components::{Physics, Color, zero_physics};

    fn execute(ctx: Context) {
        commands::set_entity('mover', (Color { c: (10, 10, 10) }, zero_physics(), ));
        commands::set_entity('seeker', (Color { c: (10, 10, 10) }, zero_physics(), ));
        return ();
    }
}

#[system]
mod Update {
    use array::ArrayTrait;
    use traits::Into;

    use dojo_autonomous_agents::components::{Physics, Color, new_physics};

    fn execute(ctx: Context) {
        let (color, physics) = commands::<Physics, Color>::entity(ctx.caller_account.into());
        let next = next_position(position, direction);
        let uh = commands::set_entity(
            ctx.caller_account.into(),
            (Color { remaining: moves.remaining - 1 }, Physics { x: next.x, y: next.y }, )
        );
        return ();
    }

    fn next_position(position: Physics, direction: Direction) -> Physics {
        match direction {
            Direction::Left(()) => {
                Physics { x: position.x - 1, y: position.y }
            },
            Direction::Right(()) => {
                Physics { x: position.x + 1, y: position.y }
            },
            Direction::Up(()) => {
                Physics { x: position.x, y: position.y - 1 }
            },
            Direction::Down(()) => {
                Physics { x: position.x, y: position.y + 1 }
            },
        }
    }
}

mod tests {
    use core::traits::Into;
    use array::ArrayTrait;

    use dojo_core::auth::systems::{Route, RouteTrait};
    use dojo_core::interfaces::IWorldDispatcherTrait;
    use dojo_core::test_utils::spawn_test_world;

    use dojo_autonomous_agents::components::PositionComponent;
    use dojo_autonomous_agents::components::MovesComponent;
    use dojo_autonomous_agents::systems::Spawn;
    use dojo_autonomous_agents::systems::Update;

    #[test]
    #[available_gas(30000000)]
    fn test_move() {
        let caller = starknet::contract_address_const::<0x1337>();
        starknet::testing::set_account_contract_address(caller);

        // components
        let mut components = array::ArrayTrait::new();
        components.append(PositionComponent::TEST_CLASS_HASH);
        components.append(MovesComponent::TEST_CLASS_HASH);
        // systems
        let mut systems = array::ArrayTrait::new();
        systems.append(Spawn::TEST_CLASS_HASH);
        systems.append(Update::TEST_CLASS_HASH);
        // routes
        let mut routes = array::ArrayTrait::new();
        routes
            .append(
                RouteTrait::new(
                    'Update'.into(), // target_id
                    'MovesWriter'.into(), // role_id
                    'Color'.into(), // resource_id
                )
            );
        routes
            .append(
                RouteTrait::new(
                    'Update'.into(), // target_id
                    'PositionWriter'.into(), // role_id
                    'Physics'.into(), // resource_id
                )
            );
        routes
            .append(
                RouteTrait::new(
                    'Spawn'.into(), // target_id
                    'MovesWriter'.into(), // role_id
                    'Color'.into(), // resource_id
                )
            );
        routes
            .append(
                RouteTrait::new(
                    'Spawn'.into(), // target_id
                    'PositionWriter'.into(), // role_id
                    'Physics'.into(), // resource_id
                )
            );

        // deploy executor, world and register components/systems
        let world = spawn_test_world(components, systems, routes);

        let spawn_call_data = array::ArrayTrait::new();
        world.execute('Spawn'.into(), spawn_call_data.span());

        let mut move_calldata = array::ArrayTrait::new();
        move_calldata.append(Update::Direction::Right(()).into());
        world.execute('Update'.into(), move_calldata.span());

        let moves = world.entity('Color'.into(), caller.into(), 0, 0);
        assert(*moves[0] == 9, 'moves is wrong');
    // let new_position = world.entity('Physics'.into(), caller.into(), 0, 0);
    // assert(*new_position[0] == 1, 'position x is wrong');
    // assert(*new_position[1] == 0, 'position y is wrong');
    }
}
