/*
  # Initial Schema Setup

  1. Tables
    - profiles
      - id (uuid, primary key)
      - created_at (timestamp)
      - updated_at (timestamp)
      - email (text)
      - role (text)
    - services
      - id (uuid, primary key)
      - created_at (timestamp)
      - title (text)
      - description (text)
      - icon (text)
    - certificates
      - id (uuid, primary key)
      - created_at (timestamp)
      - title (text)
      - issuer (text)
      - date (date)
      - image_url (text)
    - messages
      - id (uuid, primary key)
      - created_at (timestamp)
      - name (text)
      - email (text)
      - message (text)
      - status (text)

  2. Security
    - Enable RLS on all tables
    - Add policies for admin access
*/

-- Profiles table
CREATE TABLE profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  email text UNIQUE NOT NULL,
  role text DEFAULT 'user'
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage profiles"
  ON profiles
  USING (role = 'admin');

-- Services table
CREATE TABLE services (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz DEFAULT now(),
  title text NOT NULL,
  description text NOT NULL,
  icon text NOT NULL
);

ALTER TABLE services ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view services"
  ON services FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Only admins can manage services"
  ON services
  USING (EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = auth.uid()
    AND profiles.role = 'admin'
  ));

-- Certificates table
CREATE TABLE certificates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz DEFAULT now(),
  title text NOT NULL,
  issuer text NOT NULL,
  date date NOT NULL,
  image_url text
);

ALTER TABLE certificates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view certificates"
  ON certificates FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Only admins can manage certificates"
  ON certificates
  USING (EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = auth.uid()
    AND profiles.role = 'admin'
  ));

-- Messages table
CREATE TABLE messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz DEFAULT now(),
  name text NOT NULL,
  email text NOT NULL,
  message text NOT NULL,
  status text DEFAULT 'unread'
);

ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can create messages"
  ON messages FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "Only admins can view and manage messages"
  ON messages
  USING (EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = auth.uid()
    AND profiles.role = 'admin'
  ));