// Generated by dojo-bindgen on Thu, 22 Aug 2024 20:04:33 +0000. Do not modify this file manually.
// Import the necessary types from the recs SDK
// generate again with `sozo build --typescript`
import { defineComponent, Type as RecsType, World } from "@dojoengine/recs";

export type ContractComponents = Awaited<
    ReturnType<typeof defineContractComponents>
>;

// Type definition for `oz_token::models::Direction` enum
export type Direction =
    | { type: "None" }
    | { type: "Left" }
    | { type: "Right" }
    | { type: "Up" }
    | { type: "Down" };

export const DirectionDefinition = {
    type: RecsType.String,
    value: RecsType.String,
};

// Type definition for `dojo::model::layout::Layout` enum
export type Layout =
    | { type: "Fixed"; value: RecsType.NumberArray }
    | { type: "Struct"; value: RecsType.StringArray }
    | { type: "Tuple"; value: RecsType.StringArray }
    | { type: "Array"; value: RecsType.StringArray }
    | { type: "ByteArray" }
    | { type: "Enum"; value: RecsType.StringArray };

export const LayoutDefinition = {
    type: RecsType.String,
    value: RecsType.String,
};

// Type definition for `core::byte_array::ByteArray` struct
export interface ByteArray {
    data: String[];
    pending_word: BigInt;
    pending_word_len: Number;
}
export const ByteArrayDefinition = {
    data: RecsType.StringArray,
    pending_word: RecsType.BigInt,
    pending_word_len: RecsType.Number,
};

// Type definition for `dojo::model::layout::FieldLayout` struct
export interface FieldLayout {
    selector: BigInt;
    layout: Layout;
}
export const FieldLayoutDefinition = {
    selector: RecsType.BigInt,
    layout: LayoutDefinition,
};

// Type definition for `oz_token::models::Moves` struct
export interface Moves {
    player: BigInt;
    remaining: Number;
    last_direction: Direction;
    can_move: Boolean;
}
export const MovesDefinition = {
    player: RecsType.BigInt,
    remaining: RecsType.Number,
    last_direction: DirectionDefinition,
    can_move: RecsType.Boolean,
};

// Type definition for `oz_token::models::DirectionsAvailable` struct
export interface DirectionsAvailable {
    player: BigInt;
    directions: String[];
}
export const DirectionsAvailableDefinition = {
    player: RecsType.BigInt,
    directions: RecsType.StringArray,
};

// Type definition for `oz_token::systems::actions::actions::Moved` struct
export interface Moved {
    player: BigInt;
    direction: Direction;
}
export const MovedDefinition = {
    player: RecsType.BigInt,
    direction: DirectionDefinition,
};

// Type definition for `oz_token::models::Vec2` struct
export interface Vec2 {
    x: Number;
    y: Number;
}
export const Vec2Definition = {
    x: RecsType.Number,
    y: RecsType.Number,
};

// Type definition for `oz_token::models::Position` struct
export interface Position {
    player: BigInt;
    vec: Vec2;
}
export const PositionDefinition = {
    player: RecsType.BigInt,
    vec: Vec2Definition,
};

export function defineContractComponents(world: World) {
    return {
        // Model definition for `oz_token::models::Moves` model
        Moves: (() => {
            return defineComponent(
                world,
                {
                    player: RecsType.BigInt,
                    remaining: RecsType.Number,
                    last_direction: RecsType.String,
                    can_move: RecsType.Boolean,
                },
                {
                    metadata: {
                        namespace: "oz_token",
                        name: "Moves",
                        types: ["ContractAddress", "u8", "Direction", "bool"],
                        customTypes: [],
                    },
                }
            );
        })(),

        // Model definition for `oz_token::models::DirectionsAvailable` model
        DirectionsAvailable: (() => {
            return defineComponent(
                world,
                {
                    player: RecsType.BigInt,
                    directions: RecsType.StringArray,
                },
                {
                    metadata: {
                        namespace: "oz_token",
                        name: "DirectionsAvailable",
                        types: ["ContractAddress", "array"],
                        customTypes: [],
                    },
                }
            );
        })(),

        // Model definition for `oz_token::systems::actions::actions::Moved` model
        Moved: (() => {
            return defineComponent(
                world,
                {
                    player: RecsType.BigInt,
                    direction: RecsType.String,
                },
                {
                    metadata: {
                        namespace: "oz_token",
                        name: "Moved",
                        types: ["ContractAddress", "Direction"],
                        customTypes: [],
                    },
                }
            );
        })(),

        // Model definition for `oz_token::models::Position` model
        Position: (() => {
            return defineComponent(
                world,
                {
                    player: RecsType.BigInt,
                    vec: Vec2Definition,
                },
                {
                    metadata: {
                        namespace: "oz_token",
                        name: "Position",
                        types: ["ContractAddress"],
                        customTypes: ["Vec2"],
                    },
                }
            );
        })(),
    };
}
