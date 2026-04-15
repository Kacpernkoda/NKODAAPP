-- Utworzenie tabeli Produktów (Folie)
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nazwa VARCHAR(255) NOT NULL,
  seria VARCHAR(100) NOT NULL, -- np. IMPACT, VAPOR, COLOR VIBE
  opis TEXT,
  link_do_miniaturki_koloru TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Utworzenie tabeli Instalatorów
CREATE TABLE installers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nazwa_studia VARCHAR(255) NOT NULL,
  miasto VARCHAR(100) NOT NULL,
  adres TEXT NOT NULL,
  email VARCHAR(255),
  telefon VARCHAR(50),
  status_autoryzacji BOOLEAN DEFAULT false, -- true dla autoryzowanych
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Utworzenie tabeli Realizacji z powiązaniami (Foreign Keys)
CREATE TABLE realizations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  installer_id UUID REFERENCES installers(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  link_do_zdjecia_auta TEXT NOT NULL,
  model_auta VARCHAR(150),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Zabezpieczenia (Row Level Security - RLS)
-- Włączamy RLS, aby w przyszłości móc kontrolować dostęp (np. zapis tylko dla adminów)
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE installers ENABLE ROW LEVEL SECURITY;
ALTER TABLE realizations ENABLE ROW LEVEL SECURITY;

-- Zasady publicznego dostępu do ODczytu (aplikacja to klient "anon")
CREATE POLICY "Public profiles are viewable by everyone." ON products FOR SELECT USING (true);
CREATE POLICY "Public installers are viewable by everyone." ON installers FOR SELECT USING (true);
-- Utworzenie tabeli Leads (Zapytania ofertowe)
CREATE TABLE leads (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  imie_firma VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  telefon VARCHAR(50),
  marka_model VARCHAR(255),
  rok_produkcji VARCHAR(10),
  ilosc VARCHAR(50), -- Full body, Full front, Inne
  kolor_symbol VARCHAR(100), -- Symbol koloru z wizualizacji
  link_do_wizualizacji TEXT, -- Link do zdjęcia w Storage
  notes TEXT, -- Treść zapytania / uwagi
  source VARCHAR(50), -- np. 'ai_visualization', 'product_catalog'
  product_name VARCHAR(255), -- Nazwa produktu z katalogu
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Zabezpieczenia RLS dla leads
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Leads are insertable by everyone." ON leads FOR INSERT WITH CHECK (true);

-- Tabela do śledzenia generacji AI (limity 3/dobę)
CREATE TABLE IF NOT EXISTS public.ai_generations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Uprawnienia dla tabeli ai_generations
ALTER TABLE public.ai_generations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable insert for everyone" ON public.ai_generations FOR INSERT WITH CHECK (true);
CREATE POLICY "Enable select for everyone" ON public.ai_generations FOR SELECT USING (true);

-- Indeks dla wydajności przy sprawdzaniu limitów
CREATE INDEX IF NOT EXISTS idx_ai_gen_device_time ON public.ai_generations(device_id, created_at);
CREATE POLICY "Leads are viewable by authenticated users only." ON leads FOR SELECT USING (auth.role() = 'authenticated');
