Node[][] nodes;

Vec3 orig_pos;

float rod_length = 0.2;
float scene_scale;

int nodes_x = 20;
int nodes_y = 20;

int min_i;
int min_j;
  
float time;
float num_substeps = 10;
float num_relaxation_steps = 1;

Vec3 gravity = new Vec3(0, 10, 0);
Vec3 mouse_pos;

void setup () {
  size(500, 500, P3D);
  scene_scale = width / 10.0f;
  
  nodes = new Node[nodes_x][nodes_y];
  
  for (int i=0; i<nodes_x; i++) {
    for (int j=0; j<nodes_y; j++) {
      nodes[i][j] = new Node(new Vec3(1 + (rod_length * j), 1, 0));
    }
  }
}

void update(float dt) {
  //Vec3 norm;
  for (int i=0; i<nodes_x; i++) {
    for (int j=1; j<nodes_y; j++) {
      nodes[i][j].last_pos = nodes[i][j].pos;
      nodes[i][j].vel = nodes[i][j].vel.plus(gravity.times(dt));

      if (j < nodes_y-1) {                // node below
        nodes[i][j].vel = nodes[i][j].vel.plus(nodes[i][j+1].vel.times(dt / scene_scale));
      }
      
      if (i > 0 && i <= nodes_x-1) {      // nodes to the left
        nodes[i][j].vel = nodes[i][j].vel.plus(nodes[i-1][j].vel.times(dt / scene_scale));
      }
      
      if (i >= 0 && i < nodes_x-1) {      // nodes to the right
        nodes[i][j].vel = nodes[i][j].vel.plus(nodes[i+1][j].vel.times(dt / scene_scale));
      }
      nodes[i][j].pos = nodes[i][j].pos.plus(nodes[i][j].vel.times(dt));
      
      for (int k=0; k<num_relaxation_steps; k++) {
        Vec3 delta = nodes[i][j].pos.minus(nodes[i][j-1].pos);
        float delta_len = delta.length();
        float correction = delta_len - rod_length;
        Vec3 delta_normalized = delta.normalized();
          
        nodes[i][j].pos = nodes[i][j].pos.minus(delta_normalized.times(correction / 2));
        nodes[i][j-1].pos = nodes[i][j-1].pos.plus(delta_normalized.times(correction / 2));
        
        nodes[i][j-1].pos = nodes[i][j-1].pos;
        
        if (mousePressed && i != -1 && j != -1 && i == min_i && j == min_j) {
          nodes[i][j].pos = mouse_pos;
        } else {
          nodes[i][0].pos = new Vec3(1 + (rod_length * i), 1, 0);
        }
      }
    }
  }
  
  for (int i=0; i<nodes_x; i++) {
    for (int j=0; j<nodes_y; j++) {
      nodes[i][j].vel = nodes[i][j].pos.minus(nodes[i][j].last_pos).times(1 / dt);
    }
  }
}

void draw() {
  float dt = 0.05;
  Vec3 p1, p2, p3, p4;
  
  for (int i=0; i<num_substeps; i++) {
    time += dt / num_substeps;
    update(dt / num_substeps);
  }
  
  background(255);
  lights();
  
  pushMatrix();
  stroke(0);
  strokeWeight(0.02 * scene_scale);
  fill(255, 0, 0);
  
  for(int i=0; i<nodes_x-1; i++) {
    for (int j=0; j<nodes_y-1; j++) {
      p1 = nodes[i][j].pos.times(scene_scale);
      p2 = nodes[i+1][j].pos.times(scene_scale);
      p3 = nodes[i+1][j+1].pos.times(scene_scale);
      p4 = nodes[i][j+1].pos.times(scene_scale);
      
      beginShape();
      
      vertex(p1.x, p1.y, p1.z);
      vertex(p2.x, p2.y, p2.z);
      vertex(p3.x, p3.y, p3.z);
      vertex(p4.x, p4.y, p4.z);
      
      endShape(CLOSE);
    }
  }
  popMatrix();
}

void mousePressed() {
  mouse_pos = new Vec3(mouseX / scene_scale, mouseY / scene_scale, 0);
  
  float dist=0;
  
  float min_dist = mouse_pos.distanceTo(nodes[0][0].pos);
  min_i = -1;
  min_j = -1;
  
  for (int i=0; i<nodes_x; i++) {
    for (int j=1; j<nodes_y; j++) {
      dist = mouse_pos.distanceTo(nodes[i][j].pos);
      if (dist <= 0.25 && dist <= min_dist) {
        min_i = i;
        min_j = j;
      }
    }
  }
  
  if (min_i != -1 && min_j != -1) {
    orig_pos = nodes[min_i][min_j].pos;
  }
}

void mouseDragged() {
  mouse_pos = new Vec3(mouseX / scene_scale, mouseY / scene_scale, 0);
  if (min_i != -1 && min_j != -1) {
    nodes[min_i][min_j].pos = mouse_pos;
  }
}

void mouseReleased() {
  mouse_pos = new Vec3(mouseX / scene_scale, mouseY / scene_scale, 0);
  
  
  if (min_i != -1 && min_j != -1) {
    Vec3 new_vel = mouse_pos.minus(orig_pos);
    nodes[min_i][min_j].vel = nodes[min_i][min_j].vel.plus(new_vel);
  }
}

// Vec 3 Library                      // Modifies the Vec2 library from class to 3D
public class Vec3 {
  public float x, y, z;
  
  public Vec3(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
  
  public String toString() {
    return "(" + x + "," + y + "," + z + ")";
  }
  
  public float length() {
    return sqrt(x * x + y * y + z * z);
  }
  
  public float lengthSqr() {
    return x * x + y * y + z * z;
  }
  
  public Vec3 plus(Vec3 rhs) {
    return new Vec3(x + rhs.x, y + rhs.y, z + rhs.z);
  }
  
  public void add(Vec3 rhs) {
    x += rhs.x;
    y += rhs.y;
    z += rhs.z;
  }
  
  public Vec3 minus(Vec3 rhs) {
    return new Vec3(x - rhs.x, y - rhs.y, z - rhs.z);
  }

  public void subtract(Vec3 rhs) {
    x -= rhs.x;
    y -= rhs.y;
    z -= rhs.z;
  }
  
  public Vec3 times(float rhs) {
    return new Vec3(x * rhs, y * rhs, z * rhs);
  }

  public void mul(float rhs) {
    x *= rhs;
    y *= rhs;
    z *= rhs;
  }
  
  public void clampToLength(float maxL) {
    float magnitude = sqrt(x * x + y * y + z * z);
    if (magnitude > maxL) {
      x *= maxL / magnitude;
      y *= maxL / magnitude;
      z *= maxL / magnitude;
    }
  }

  public void setToLength(float newL) {
    float magnitude = sqrt(x * x + y * y + z * z);
    x *= newL / magnitude;
    y *= newL / magnitude;
    z *= newL / magnitude;
  }
  
  public void normalize() {
    float magnitude = sqrt(x * x + y * y + z * z);
    x /= magnitude;
    y /= magnitude;
    z /= magnitude;
  }

  public Vec3 normalized() {
    float magnitude = sqrt(x * x + y * y + z * z);
    return new Vec3(x / magnitude, y / magnitude, z / magnitude);
  }

  public float distanceTo(Vec3 rhs) {
    float dx = rhs.x - x;
    float dy = rhs.y - y;
    float dz = rhs.z - z;
    
    return sqrt(dx * dx + dy * dy + dz * dz);
  }
}

Vec3 interpolate(Vec3 a, Vec3 b, float t) {
  return a.plus((b.minus(a)).times(t));
}

float interpolate(float a, float b, float t) {
  return a + ((b - a) * t);
}

float dot(Vec3 a, Vec3 b) {
  return a.x * b.x + a.y * b.y + a.z * b.z;
}

// Added Vec3 functions
Vec3 cross(Vec3 a, Vec3 b) {
  return new Vec3(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x);
}

Vec3 midpoint(Vec3 a, Vec3 b) {
  return new Vec3((a.x + b.x) / 2, (a.y + b.y) / 2, (a.z +  b.z) / 2);
}

// Node struct                   // From DoublePendulum_Exercise
public class Node {                          // modified for 3D
  Vec3 pos;
  Vec3 vel;
  Vec3 last_pos;

  Node(Vec3 pos) {
    this.pos = pos;              // current position
    this.vel = new Vec3(0, 0, 0);   // current velocity; default = 0
    this.last_pos = pos;          // previous position
  }
}
