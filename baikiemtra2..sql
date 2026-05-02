CREATE DATABASE QuanLyThuVien_K235480106102;
GO
USE QuanLyThuVien_K235480106102;
CREATE TABLE [DocGia] (
    [DocGiaId] INT PRIMARY KEY IDENTITY, -- PK
    [TenDocGia] NVARCHAR(100) NOT NULL,
    [NgaySinh] DATE,
    [SoDienThoai] VARCHAR(15),
    [TrangThai] NVARCHAR(20) CHECK ([TrangThai] IN (N'Hoạt động', N'Khóa')) -- CK
);
CREATE TABLE [Sach] (
    [SachId] INT PRIMARY KEY IDENTITY, -- PK
    [TenSach] NVARCHAR(200) NOT NULL,
    [GiaTien] MONEY CHECK ([GiaTien] >= 0), -- CK
    [SoLuong] INT CHECK ([SoLuong] >= 0) -- CK
);
CREATE TABLE [MuonSach] (
    [MuonId] INT IDENTITY(1,1) PRIMARY KEY,
    [DocGiaId] INT NOT NULL,
    [SachId] INT NOT NULL,
    [NgayMuon] DATE NOT NULL,
    [NgayTra] DATE NULL
);
GO

ALTER TABLE [MuonSach]
ADD CONSTRAINT [FK_MuonSach_DocGia]
FOREIGN KEY ([DocGiaId]) REFERENCES [DocGia]([DocGiaId]);
GO

ALTER TABLE [MuonSach]
ADD CONSTRAINT [FK_MuonSach_Sach]
FOREIGN KEY ([SachId]) REFERENCES [Sach]([SachId]);
GO
SELECT GETDATE() AS NgayHienTai;
SELECT LEN(N'Nguyen Duy') AS DoDai;
SELECT DATEDIFF(DAY, '2024-01-01', GETDATE()) AS SoNgay;
CREATE FUNCTION fn_TinhSoNgayMuon (@NgayMuon DATE, @NgayTra DATE)
RETURNS INT
AS
BEGIN
    RETURN DATEDIFF(DAY, @NgayMuon, @NgayTra);
END;
CREATE FUNCTION fn_SachConLai ()
RETURNS TABLE
AS
RETURN (
    SELECT * FROM [Sach]
    WHERE [SoLuong] > 0
);
CREATE FUNCTION fn_DocGiaMuonNhieu (@SoLan INT)
RETURNS @KQ TABLE (
    DocGiaId INT,
    TenDocGia NVARCHAR(100),
    SoLanMuon INT
)
AS
BEGIN
    INSERT INTO @KQ
    SELECT d.DocGiaId, d.TenDocGia, COUNT(*)
    FROM [DocGia] d
    JOIN [MuonSach] m ON d.DocGiaId = m.DocGiaId
    GROUP BY d.DocGiaId, d.TenDocGia
    HAVING COUNT(*) > @SoLan;

    RETURN;
END;
CREATE PROCEDURE sp_ThemSach
    @TenSach NVARCHAR(200),
    @Gia MONEY,
    @SoLuong INT
AS
BEGIN
    IF @SoLuong < 0
        PRINT N'Số lượng không hợp lệ'
    ELSE
        INSERT INTO [Sach] VALUES (@TenSach, @Gia, @SoLuong)
END;
CREATE PROCEDURE sp_TongSach
    @Tong INT OUTPUT
AS
BEGIN
    SELECT @Tong = SUM([SoLuong]) FROM [Sach];
END;
CREATE PROCEDURE sp_DanhSachMuon
AS
BEGIN
    SELECT d.TenDocGia, s.TenSach, m.NgayMuon
    FROM [MuonSach] m
    JOIN [DocGia] d ON m.DocGiaId = d.DocGiaId
    JOIN [Sach] s ON m.SachId = s.SachId;
END;
CREATE TRIGGER trg_MuonSach_Insert
ON [MuonSach]
AFTER INSERT
AS
BEGIN
    UPDATE s
    SET s.SoLuong = s.SoLuong - 1
    FROM [Sach] s
    JOIN inserted i ON s.SachId = i.SachId;
END;

DELETE FROM [MuonSach];
DELETE FROM [Sach];
DELETE FROM [DocGia];

INSERT INTO [DocGia] (TenDocGia, NgaySinh, SoDienThoai, TrangThai)
VALUES 
(N'Nguyễn Văn An', '2000-01-01', '0900000001', N'Hoạt động'),
(N'Trần Thị Bình', '1999-05-10', '0900000002', N'Hoạt động'),
(N'Lê Văn Cường', '2001-03-15', '0900000003', N'Khóa'),
(N'Phạm Thị Dung', '1998-07-20', '0900000004', N'Hoạt động'),
(N'Hoàng Văn Em', '2002-11-11', '0900000005', N'Hoạt động');


INSERT INTO [Sach] (TenSach, GiaTien, SoLuong)
VALUES
(N'Lập trình SQL cơ bản', 100000, 10),
(N'Cấu trúc dữ liệu', 120000, 8),
(N'Giải thuật nâng cao', 150000, 5),
(N'Cơ sở dữ liệu', 130000, 7),
(N'Python cho người mới', 110000, 12);

INSERT INTO [MuonSach] (DocGiaId, SachId, NgayMuon, NgayTra)
VALUES
(1, 1, '2024-01-01', '2026-01-05'),
(1, 2, '2024-01-10', '2026-01-15'),
(2, 1, '2024-02-01', '2026-02-10'),
(2, 3, '2024-02-05', '2026-02-20'),
(3, 4, '2024-03-01', '2026-03-07'),
(4, 5, '2024-03-10', '2026-03-15'),
(5, 1, '2024-04-01', '2026-04-05'),
(5, 2, '2024-04-06', '2026-04-10');

SELECT dbo.fn_TinhSoNgayMuon('2024-01-01','2024-01-10') AS SoNgayMuon;

SELECT * FROM dbo.fn_SachConLai();

SELECT * FROM dbo.fn_DocGiaMuonNhieu(1);


DECLARE @Tong INT;
EXEC sp_TongSach @Tong OUTPUT;
PRINT N'Tổng số sách: ' + CAST(@Tong AS NVARCHAR);

EXEC sp_DanhSachMuon;


DECLARE @TenSach NVARCHAR(200), @SoLuong INT;

DECLARE cur CURSOR FOR
SELECT TenSach, SoLuong FROM [Sach];

OPEN cur;
FETCH NEXT FROM cur INTO @TenSach, @SoLuong;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF @SoLuong = 0
        PRINT @TenSach + N' đã hết hàng';

    FETCH NEXT FROM cur INTO @TenSach, @SoLuong;
END;

CLOSE cur;
DEALLOCATE cur;