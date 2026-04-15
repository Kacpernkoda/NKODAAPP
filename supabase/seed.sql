-- Skrypt do skopiowania i uruchomienia w panelu SQL Editor na stronie Supabase
-- Upewnij się najpierw, że zaktualizowałeś strukturę tabeli installers o pole 'email' (lub usuń tabelę i stwórz na nowo wg nowego schema.sql).

-- Jeśli masz już tabele, możesz po prostu wywołać ALTER TABLE:
ALTER TABLE IF EXISTS installers ADD COLUMN IF NOT EXISTS email VARCHAR(255);

-- Oczyszczenie obecnych (jeśli jakieś są) by nie zduplikować
-- DELETE FROM installers; 

INSERT INTO installers (nazwa_studia, adres, miasto, email, telefon, status_autoryzacji)
VALUES
('NKODA Europe', 'Odlewnicza 4a (Hala B)', 'Warszawa', 'ppf@nkodaeurope.com', '+48 730 234 234', true),
('4ohmy', 'ul. Wrocławska 41', 'Krępice', 'biuro@4ohmy.pl', '792 545 523', true),
('PERFEKT Design - Rafał Poprawa', 'Skarszewek 48E', 'Żelazków', 'perfektcarscare@gmail.com', '504 256 115', true),
('Prestige detailing', 'Mieszka I 82/83', 'Szczecin', 'biuro@prestige-detailing.pl', '+48 666 683 858', true),
('Carwrappoland', 'ul. Bodycha 41c', 'Warszawa', 'kontakt@carwrappoland.pl', '+48 509 348 669', true),
('Anioła Detailing & Performance', 'ul. Klenowska 7', 'Poznań', 'Aniola.detailing@gmail.com', '889 819 858', false),
('Studio detailingu Morena', 'Jaśkowa Dolina 132', 'Gdańsk', 'detailingmorena@op.pl', '+48 886 069 886', true),
('DarkGlass - Oklejanie i Autospa', 'Ul. 3 maja 165', 'Chorzów', 'info@darkglass.pl', '+48 519 445 485', false);
