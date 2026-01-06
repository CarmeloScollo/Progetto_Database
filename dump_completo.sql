-- Creazione del database
CREATE DATABASE IF NOT EXISTS Libreria;
USE Libreria;

-- Creazione della tabella Utente
CREATE TABLE Utente (
    Username VARCHAR(16) NOT NULL,
    Password VARCHAR(16) NOT NULL,
    Email VARCHAR(32) NOT NULL UNIQUE,
    Nome VARCHAR(16) NOT NULL,
    Cognome VARCHAR(16) NOT NULL,
    Saldo FLOAT(8) NOT NULL,
    PRIMARY KEY (Username)
);

-- Creazione della tabella Autore
CREATE TABLE Autore (
    ID_Autore INT NOT NULL AUTO_INCREMENT,
    Nome VARCHAR(32) NOT NULL,
    Biografia TEXT,
    PRIMARY KEY (ID_Autore)
);

-- Creazione della tabella Editore
CREATE TABLE Editore (
    ID_Editore INT NOT NULL AUTO_INCREMENT,
    Nome VARCHAR(64) NOT NULL,
    IBAN VARCHAR(34) NOT NULL,
    Partita_IVA VARCHAR(11) NOT NULL,
    PRIMARY KEY (ID_Editore)
);

-- Creazione della tabella Libro
CREATE TABLE Libro (
    ID_Libro INT NOT NULL AUTO_INCREMENT,
    Prezzo FLOAT(8) NOT NULL,
    Formato VARCHAR(8) NOT NULL,
    ID_Editore INT NOT NULL,
    PRIMARY KEY (ID_Libro),
    FOREIGN KEY (ID_Editore) REFERENCES Editore(ID_Editore)
);

-- Creazione della tabella Scrive
CREATE TABLE Scrive (
    ID_Libro INT NOT NULL,
    ID_Autore INT NOT NULL,
    PRIMARY KEY (ID_Libro, ID_Autore),
    FOREIGN KEY (ID_Libro) REFERENCES Libro(ID_Libro),
    FOREIGN KEY (ID_Autore) REFERENCES Autore(ID_Autore)
);

-- Creazione della tabella Acquisto
CREATE TABLE Acquisto (
    ID_Acquisto INT NOT NULL AUTO_INCREMENT,
    Costo FLOAT(8) NOT NULL,
    Data DATE NOT NULL,
    Username VARCHAR(16) NOT NULL,
    PRIMARY KEY (ID_Acquisto),
    FOREIGN KEY (Username) REFERENCES Utente(Username)
);

-- Creazione della tabella Contiene
CREATE TABLE Contiene (
    ID_Acquisto INT NOT NULL,
    ID_Libro INT NOT NULL,
    PRIMARY KEY (ID_Acquisto, ID_Libro),
    FOREIGN KEY (ID_Acquisto) REFERENCES Acquisto(ID_Acquisto),
    FOREIGN KEY (ID_Libro) REFERENCES Libro(ID_Libro)
);

-- Creazione della tabella Accredito
CREATE TABLE Accredito (
    ID_Accredito INT NOT NULL AUTO_INCREMENT,
    Metodo VARCHAR(2) NOT NULL,
    Importo FLOAT(8) NOT NULL,
    Data DATE NOT NULL,
    Username VARCHAR(16) NOT NULL,
    PRIMARY KEY (ID_Accredito),
    FOREIGN KEY (Username) REFERENCES Utente(Username)
);

-- Operazione n.1: Creare un account di un utente
INSERT INTO Utente (Username, Password, Email, Nome, Cognome, Saldo) VALUES ('user123', 'password', 'user@example.com', 'Mario', 'Rossi', 100.00);

-- Operazione n.2: Inserire dati di un editore
INSERT INTO Editore (Nome, IBAN, Partita_IVA) VALUES ('Mondadori', 'IT60X0542811101000000123456', '12345678901');

-- Operazione n.3: Inserire dati di un autore
INSERT INTO Autore (Nome, Biografia) VALUES ('Dante Alighieri', 'Poeta italiano del medioevo.');

-- Operazione n.4: Inserire dati di un libro
INSERT INTO Libro (Prezzo, Formato, ID_Editore) VALUES (9.99, 'Cartaceo', 1);

-- Operazione n.5: Completare un acquisto
INSERT INTO Acquisto (Costo, Data, Username) VALUES (9.99, '2024-02-28', 'user123');
INSERT INTO Contiene (ID_Acquisto, ID_Libro) VALUES (1, 1);

-- Trigger per controllare se l'acquirente ha saldo sufficiente
CREATE TRIGGER CheckSaldo BEFORE INSERT ON Acquisto FOR EACH ROW BEGIN
    IF NEW.Costo > (SELECT Saldo FROM Utente WHERE Username = NEW.Username) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Acquisto non completato';
    END IF;
END;

-- Trigger per aggiornare il saldo dell'utente dopo un acquisto
CREATE TRIGGER AggiornaSaldo AFTER INSERT ON Acquisto FOR EACH ROW BEGIN
    UPDATE Utente SET Saldo = Saldo - NEW.Costo WHERE Username = NEW.Username;
END;

-- Operazione n.6: Mostrare i libri di un acquisto
SELECT L.ID_Libro, L.ID_Editore, L.Formato FROM Contiene C JOIN Libro L ON C.ID_Libro = L.ID_Libro WHERE C.ID_Acquisto = 1;

-- Operazione n.7: Mostrare il prezzo di un libro
SELECT Prezzo FROM Libro WHERE ID_Libro = 1;

-- Operazione n.8: Mostrare il costo dell’acquisto
SELECT Costo FROM Acquisto WHERE ID_Acquisto = 1;

-- Operazione n.9: Mostrare il saldo di un utente
SELECT Saldo FROM Utente WHERE Username = 'user123';

-- Operazione n.10: Effettuare un accredito
INSERT INTO Accredito (Metodo, Importo, Data, Username) VALUES ('CC', 50.00, '2024-02-28', 'user123');
UPDATE Utente SET Saldo = Saldo + 50.00 WHERE Username = 'user123';

-- Operazione n.11: Ricercare un libro per il suo formato
SELECT ID_Libro FROM Libro WHERE Formato = 'Cartaceo';

-- Operazione n.12: Modificare il prezzo di un libro
UPDATE Libro SET Prezzo = 12.99 WHERE ID_Libro = 1;

-- Operazione n.13: Ricercare il libro per un autore
SELECT ID_Libro FROM Scrive WHERE ID_Autore = 1;