-- 1. Dodanie kolumny województwo (jeśli jeszcze nie istnieje)
ALTER TABLE installers ADD COLUMN IF NOT EXISTS wojewodztwo VARCHAR(100);

-- 2. Import danych partnerów (używamy UPSERT na podstawie nazwy studia i adresu)
-- Unikalny indeks na (nazwa_studia, adres) musi istnieć dla ON CONFLICT, jeśli nie istnieje - stworzymy go tymczasowo
CREATE UNIQUE INDEX IF NOT EXISTS installers_name_address_idx ON installers (nazwa_studia, adres);

INSERT INTO installers (nazwa_studia, miasto, adres, email, telefon, status_autoryzacji, wojewodztwo)
VALUES
('DarkGlass - Oklejanie i Autospa', 'Chorzów', 'Ul. 3 maja 165, 41-500 Chorzów', 'info@darkglass.pl', '+48 519 445 485', true, 'Śląskie'),
('Custom Design', 'Tomaszów Lubelski', 'ul.Petera 60 Tomaszów Lubelski', 'marek.biszczanik@wp.pl', '536 831 603', true, 'Lubelskie'),
('pm-detailing', 'Gorlice', 'Zakole 14, Gorlice, Poland', 'detailingpm@gmail.com', '+48 509 869 243', true, 'Małopolskie'),
('FABRYKA POŁYSKU', 'Kolbuszowa', 'Nowa Wieś 216, 36-100 Kolbuszowa', 'biuro@fabrykapolysku.pl', '669-426-608', true, 'Podkarpackie'),
('Grupa Wróbel - Mercedes-Benz', 'Wrocław', 'ul. Graniczna 4A 54-610 Wrocław', NULL, NULL, true, 'Dolnośląskie'),
('R33 - Car Wrap & Protection', 'Opole', 'Wrocławska 326, 45-960 Opole', 'biuro@r33.pl', '791 185 777', true, 'Opolskie'),
('car shine', 'Władysławowo', 'Gdańska 115, Władysławowo, Poland', NULL, '+48 537 111 101', true, 'Pomorskie'),
('CAR ACADEMY', 'Ostrów Wielkopolski', 'Wrocławska 226 / 1, 63-400 Ostrów Wielkopolski, Polska', 'szymonii@o2.pl', NULL, true, 'Wielkopolskie'),
('Bear Garage', 'Węgrzce', 'C3 50, 32-086 Węgrzce', 'kontakt@beargarage.pl', '788512204', true, 'Małopolskie'),
('Super Shine', 'Białystok', 'Składowa 11/26 15-399 Białystok', 'bok@super-shine.pl', '+48 883-774-774', true, 'Podlaskie'),
('Autotechnikum S.C.', 'Szczecin', 'Południowa 33 71-001 Szczecin', 'robert@autotechnikum.pl', '+48 663 333 959', true, 'Zachodniopomorskie'),
('Warsaw Shine', 'Warszawa', 'ul. Odkryta 60, Warszawa', 'biuro@warsawshine.pl', '+48 734 734 676', true, 'Mazowieckie'),
('Studio Cb', 'Warszawa', 'Wysockiego 40, 03-202 Warszawa', 'biuro@studiocb.pl', '600 620 150', true, 'Mazowieckie'),
('Wrapstyle', 'Zlín', 'tř. T. Bati 627 763 02 Zlín, Czech Republic', 'info@wrapstyle.com', NULL, true, 'Zlínský kraj (Czechy)'),
('Mrfoxpoland', 'Tłokinia Kościelna', 'Kaliska 25 62-860 Tłokinia Kościelna', 'info@mrfoxpoland.com', '+48 62 752 93 11', true, 'Wielkopolskie'),
('Shineon', 'Dawidy', 'Warszawska 49, 05-090 Dawidy', 'studio@shineon.pl', '+48 500 140 002', true, 'Mazowieckie'),
('Black Glass', 'Jelenia Góra', 'Jelenia Góra ul. Wincentego Pola 8', NULL, '663 442 021', true, 'Dolnośląskie'),
('Pmcustoms', 'Chrząszczyce', 'ul. Szkolna 20 46-060 Chrząszczyce /k. Opola', 'biuro@pmcustoms.pl', '+48 511 941 690', true, 'Opolskie'),
('Autodetailing', 'Starowa Góra', 'ul. Szeroka 32 95-030 Starowa Góra', 'kontakt@autodetailing.zone', '530 595 600', true, 'Łódzkie'),
('Deep Shine', 'Szczecin', 'Ul. Łukasińskiego 108A, 71-215 Szczecin', NULL, '+48 512 360 901', true, 'Zachodniopomorskie'),
('Studio Folia', 'Warszawa', 'Warszawa ul. Byczyńska 29', 'biuro@studiofolia.pl', '516311040', true, 'Mazowieckie'),
('Niesco Detailing', 'Warszawa', 'ul. Mrówcza 239 / 04-697 Warszawa', 'biuro@atumplus.pl', '+48 500 351 110', true, 'Mazowieckie'),
('Auto Myjnia GTLux Partner', 'Opole', 'Głogowska 17A, 45-315 Opole', 'biuro@gtlux.pl', '+48 790 707 600', true, 'Opolskie'),
('Axis Auto Detailing', 'Warszawa', 'Łukasza Drewny 19 Powsin, 02-969 Warszawa', 'powsin@axisdetailing.pl', '+ 48 793 782 866', true, 'Mazowieckie'),
('Axis Auto Detailing', 'Warszawa', 'Wiertnicza 61, 02-953 Warszawa', 'kontakt@axisdetailing.pl', '+48516782866', true, 'Mazowieckie'),
('c7 studio', 'Kraków', 'Kraków, ul. Cechowa 7a', 'biuro@c7studio.pl', '+48 514 828 519', true, 'Małopolskie'),
('Atumplus', 'Warszawa', 'ul. Mrówcza 239 , 04-697 Warszawa', 'biuro@atumplus.pl', '500 351 110', true, 'Mazowieckie'),
('cityvinci', 'Lublin', 'Fabryczna 2, Lublin, Poland', 'cityvinci@gmail.com', '+48 661 600 638', true, 'Lubelskie'),
('Golden Car', 'Ostrów Mazowiecka', 'Podborze 13, Ostrów Mazowiecka, Poland', NULL, '+48 884 869 585', true, 'Mazowieckie'),
('WRAP ART', 'Kraków', 'Łagiewnicka 52, Kraków, Poland', 'wrapart.detailing@gmail.com', '+48 667 661 676', true, 'Małopolskie'),
('FRESH Łomża', 'Łomża', 'Zjazd 16a, Łomża, Poland', 'freshlomza@gmail.com', '+48 505 134 135', true, 'Podlaskie'),
('CARSAN', 'Warszawa', 'ul. Poleczki 23F, Warszawa 02-822', 'biuro@carsan.pl', '604 545 426', true, 'Mazowieckie'),
('GRUPA KARLIK SPÓŁKA JAWNA', 'Poznań', 'Kaliska 28, 61-131 Poznań', NULL, NULL, true, 'Wielkopolskie'),
('CARAP Finest Media', 'Wolfratshausen', 'Auenstraße 2, 82515 Wolfratshausen, Niemcy', 'office@carap.de', '+49 (0)173 58 67 898', true, 'Bayern (Niemcy)'),
('CarBuff Detailing Gdansk', 'Bąkowo', 'kpt. Konstantego Maciejewicza 30, 83-050 Bąkowo', 'carbuffpl@gmail.com', '690 525 925', true, 'Pomorskie'),
('CarInStyle', 'Rožnov pod Radhoštěm', 'Meziříčská 496, 756 61 Rožnov pod Radhoštěm 1, Czechy', 'info@carinstyle.cz', '+420604602414', true, 'Zlínský kraj (Czechy)'),
('Sobesto Detailing', 'Biertowice', 'Krakowska 101, 32-440 Biertowice', 's.sobesto@gmail.com', '697 779 488', true, 'Małopolskie'),
('One Way', 'Warszawa', 'Odlewnicza 4, 03-231 Warszawa, Polska', 'oneway.warszawa@gmail.com', NULL, true, 'Mazowieckie'),
('MICHAŁ KOŃCZAKOWSKI K-GROUP', 'Kraków', 'ul. Józefa Chełmońskiego 11A/2, 31-301 Kraków', 'michal@konczakowski.pl', NULL, true, 'Małopolskie'),
('VCENTRUM GRUPA SPÓŁKA AKCYJNA', 'Warszawa', 'Jana Pawła Woronicza 19, 02-625 Warszawa, Polska', NULL, '+48 22 264 32 50', true, 'Mazowieckie'),
('GLANCAUTO', 'Małkowo', 'Gdyńska 16, 83-330 Małkowo', 'glancbiuro@wp.pl', '507 684 950', true, 'Pomorskie'),
('Auto Group Polska Sp. z o.o', 'Wrocław', 'Aleja Aleksandra Brücknera 40-46, 51-411 Wrocław', NULL, NULL, true, 'Dolnośląskie'),
('CAR ESTETIC', 'Rzgów', 'UL. RZEMIEŚLNICZA 24, 95-030 RZGÓW', NULL, NULL, true, 'Łódzkie'),
('UNDERCOVER', 'Ząbki', 'ul. Zakopiańska 2A 05-091 Ząbki k/Warszawy', 'kontakt@undercover.pl', '883992622', true, 'Mazowieckie'),
('AUTOKAMELEON', 'Lubiszyn', '1A, Tarnów, 66-433 Lubiszyn, Polska', 'kontakt@autokameleon.pl', '601 715 560', true, 'Lubuskie'),
('Golden Car Wojciech Radys', 'Wolin', 'ul. Jana Matejki 7, 72-510 Wolin', 'detailinggoldencar@gmail.com', NULL, true, 'Zachodniopomorskie'),
('MOTO-KING', 'Otwock', 'Stefana Żeromskiego 121B, 05-400 Otwock', NULL, NULL, true, 'Mazowieckie'),
('LUXURY CAR CARE', 'Chojęcin', 'Warszawska 58, 63-640 Chojęcin', 'dawidwoznica64@gmail.com', '739 010 767', true, 'Wielkopolskie'),
('DanielitoCarDetailing', 'Koło', 'Cegielniana 4, 62-600 Koło', 'danielito.detailing@gmail.com', '661 546 407', true, 'Wielkopolskie')
ON CONFLICT (nazwa_studia, adres) 
DO UPDATE SET 
  miasto = EXCLUDED.miasto,
  email = EXCLUDED.email,
  telefon = EXCLUDED.telefon,
  status_autoryzacji = EXCLUDED.status_autoryzacji,
  wojewodztwo = EXCLUDED.wojewodztwo;
