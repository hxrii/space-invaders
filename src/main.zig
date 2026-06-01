const rl = @import("raylib");

const Rectangle = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,

    pub fn intersects(self: Rectangle, other: Rectangle) bool {
        return self.x < other.x + self.width and
            self.x + self.width > other.x and
            self.y < other.y + other.height and
            self.y + self.height > other.y;
    }
};

const GameConfig = struct { screenWidth: i32, screenHeight: i32, playerWidth: i32, playerHeight: i32, playerStartY: i32, bulletWidth: f32, bulletHeight: f32, shieldStartX: f32, shieldY: f32, shieldWidth: f32, shieldHeight: f32, shieldSpacing: f32, invaderStartX: f32, invaderStartY: f32, invaderHeightX: f32, invaderHeightY: f32, InvaderSpacingX: f32, InvaderSpacingY: f32 };

const Player = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    speed: f32,

    pub fn init(position_x:f32, position_y:f32, width: f32, height: f32) @This(){
        return Player{
            .position_x:f32 = position_x,
            .position_y:f32 = position_y,
            .width:f32 = width,
            .height:f32 = height
        }
    }
};



pub fn main() void {
    const screen_width = 800;
    const screen_height = 600;

    rl.initWindow(screen_width, screen_height, "Zig Invaders");

    defer rl.closeWindow();
    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);
        rl.drawText("Zig Invaders", 300, 250, 40, rl.Color.green);
    }

    return;
}
