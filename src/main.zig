const rl = @import("raylib");

const Rectangle = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,

    pub fn intersects(self: Rectangle, other: Rectangle) bool {
        return self.x < other.x + other.width and
            self.x + self.width > other.x and
            self.y < other.y + other.height and
            self.y + self.height > other.y;
    }
};

const GameConfig = struct {
    screenWidth: i32,
    screenHeight: i32,
    playerWidth: i32,
    playerHeight: i32,
    playerStartY: i32,
    bulletWidth: f32,
    bulletHeight: f32,
    shieldStartX: f32,
    shieldY: f32,
    shieldWidth: f32,
    shieldHeight: f32,
    shieldSpacing: f32,
    invaderStartX: f32,
    invaderStartY: f32,
    invaderHeightX: f32,
    invaderHeightY: f32,
    InvaderSpacingX: f32,
    InvaderSpacingY: f32,
};

const Player = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    speed: f32,

    pub fn init(position_x: f32, position_y: f32, width: f32, height: f32) @This() {
        return Player{ .position_x = position_x, .position_y = position_y, .width = width, .height = height, .speed = 5.0 };
    }

    pub fn update(self: *@This()) void {
        if (rl.isKeyDown(rl.KeyboardKey.right)) {
            self.position_x += self.speed;
        }

        if (rl.isKeyDown(rl.KeyboardKey.left)) {
            self.position_x -= self.speed;
        }

        if (self.position_x <= 0) {
            self.position_x = 0;
        }

        if (self.position_x + self.width > @as(f32, @floatFromInt(rl.getScreenWidth()))) {
            self.position_x = @as(f32, @floatFromInt(rl.getScreenWidth())) - self.width;
        }
    }

    pub fn getRect(self: @This()) Rectangle {
        return .{
            .x = self.position_x,
            .y = self.position_y,
            .width = self.width,
            .height = self.height,
            .speed = self.speed,
        };
    }

    pub fn draw(self: @This()) void {
        rl.drawRectangle(
            @intFromFloat(self.position_x),
            @intFromFloat(self.position_y),
            @intFromFloat(self.width),
            @intFromFloat(self.height),
            rl.Color.blue,
        );
    }
};

pub fn main() void {
    const screen_width = 800;
    const screen_height = 600;

    rl.initWindow(screen_width, screen_height, "Zig Invaders");

    defer rl.closeWindow();

    const player_width = 50.0;
    const player_height = 30.0;
    var player = Player.init(
        @as(f32, @floatFromInt(screen_width)) / 2 - player_width / 2,
        @as(f32, @floatFromInt(screen_height)) - 60.0,
        player_width,
        player_height,
    );

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        player.update();
        player.draw();
        rl.drawText("Zig Invaders", 300, 250, 40, rl.Color.green);
    }

    return;
}
