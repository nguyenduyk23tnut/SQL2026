# BÀI KIỂM TRA SỐ 2 – HỆ QUẢN TRỊ CSDL

# Thông tin sinh viên

- Họ tên: NGUYỄN DUY
- Mã SV: K235480106102
- Chủ đề: Quản lý thư viện sách

# Phần 1: Thiết kế và Khởi tạo Cấu trúc Dữ liệu

## 1. Tạo database 
```sql
CREATE DATABASE QuanLyThuVien_K235480106102;
GO
USE QuanLyThuVien_K235480106102;
```
<img width="1919" height="1079" alt="Screenshot 2026-05-02 100037" src="https://github.com/user-attachments/assets/ecb58ca0-824c-4132-8668-940c56004e21" />

- Tạo database thành công

 ## 2. Tạo bảng
- Tạo bảng DocGia:

 ```sql
CREATE TABLE [DocGia] (
    [DocGiaId] INT PRIMARY KEY IDENTITY, -- PK
    [TenDocGia] NVARCHAR(100) NOT NULL,
    [NgaySinh] DATE,
    [SoDienThoai] VARCHAR(15),
    [TrangThai] NVARCHAR(20) CHECK ([TrangThai] IN (N'Hoạt động', N'Khóa')) -- CK
);
```
<img width="1919" height="1079" alt="Screenshot 2026-05-02 100114" src="https://github.com/user-attachments/assets/fda3cc84-1aee-48ff-810d-0b00bcf47344" />
        [DocGiaId] là Primary Key (PK)
        
        → dùng để định danh duy nhất cho mỗi độc giả, không trùng lặp.
        
        [TenDocGia] dùng kiểu NVARCHAR(100)
        
        → lưu họ tên độc giả có dấu tiếng Việt.
        
        [NgaySinh] kiểu DATE
        
        → lưu ngày tháng năm sinh.
        
        [SoDienThoai] kiểu VARCHAR(15)
        
        → lưu số điện thoại.
        
        [TrangThai] có CHECK CONSTRAINT (CK):
        
        CHECK ([TrangThai] IN (N'Hoạt động', N'Khóa'))
- Tạo bảng Sach:

```sql
CREATE TABLE [Sach] (
    [SachId] INT PRIMARY KEY IDENTITY, -- PK
    [TenSach] NVARCHAR(200) NOT NULL,
    [GiaTien] MONEY CHECK ([GiaTien] >= 0), -- CK
    [SoLuong] INT CHECK ([SoLuong] >= 0) -- CK
);
```
<img width="1919" height="1079" alt="Screenshot 2026-05-02 100220" src="https://github.com/user-attachments/assets/d115ef2a-1635-4457-882c-421e16554e4f" />
  [SachId] là Primary Key (PK)
  
  → mã định danh duy nhất cho từng cuốn sách.
  
  [TenSach] kiểu NVARCHAR(200)
  
  → lưu tên sách.
  
  [GiaTien] kiểu MONEY
  
  → lưu giá tiền sách.
  
  [GiaTien] có CK:
  
  CHECK ([GiaTien] >= 0)
  
  
  → giá tiền không được âm.
  
  
  [SoLuong] có CK:

  CHECK ([SoLuong] >= 0)
  
  → số lượng sách không được nhỏ hơn 0.
 
- Tạo bảng Muonsach
```sql
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
```
<img width="1919" height="1079" alt="Screenshot 2026-05-02 100859" src="https://github.com/user-attachments/assets/0c9b3921-e13c-45d5-9190-ff5554ca7aa5" />
     
  [MuonId] là Primary Key (PK)
  
  → mã phiếu mượn duy nhất.
  
  [DocGiaId] là Foreign Key (FK)
  
  → liên kết đến bảng [DocGia], xác định ai là người mượn sách.
  
  [SachId] là Foreign Key (FK)
  
  → liên kết đến bảng [Sach], xác định cuốn sách nào được mượn.
  
  [NgayMuon] lưu ngày mượn sách.
  
  [NgayTra] lưu ngày trả sách, cho phép NULL nếu chưa trả.

  ## Phần 2. Xây dựng Function 
  1. Built-in function

      GETDATE() → lấy ngày hiện tại
     
      LEN() → độ dài chuỗi
     
      DATEDIFF() → tính khoảng cách ngày
     
 ```sql
      SELECT GETDATE() AS NgayHienTai;
      SELECT LEN(N'Nguyen Duy') AS DoDai;
      SELECT DATEDIFF(DAY, '2024-01-01', GETDATE()) AS SoNgay;
  ```
  2. User Defined Function
     Đây là hàm do lập trình viên/database designer tạo ra để:

      - nhận dữ liệu đầu vào
      - xử lý theo logic mình muốn
      - trả về kết quả

     Mục đích:
      - Giảm lặp code
      - Dễ bảo trì
      - Chuẩn hóa nghiệp vụ
      - Làm câu lệnh gọn hơn

     Trong SQL Server thường học 2 loại chính:

     - Loại 1: Scalar Function
     - Loại 2: Table Valued Function

     
→ Mặc dù SQL Server đã cung cấp nhiều hàm hệ thống như xử lý chuỗi, ngày tháng hay tính toán cơ bản, nhưng các hàm đó chỉ đáp ứng những nhu cầu chung. Trong thực tế, mỗi bài toán quản lý đều có những yêu cầu nghiệp vụ riêng như tính tiền phạt trễ hạn, kiểm tra sách còn hàng hay thống kê số lượt mượn, nên người dùng cần tự viết function riêng để xử lý đúng theo mục đích của mình, đồng thời giúp tái sử dụng mã lệnh và làm câu truy vấn ngắn gọn hơn

  3. Scalar Function( Tính số ngày mượn sách):
```sql
CREATE FUNCTION fn_TinhSoNgayMuon (@NgayMuon DATE, @NgayTra DATE)
RETURNS INT
AS
BEGIN
    RETURN DATEDIFF(DAY, @NgayMuon, @NgayTra);
END;
```
  <img width="1919" height="1079" alt="Screenshot 2026-05-02 101206" src="https://github.com/user-attachments/assets/a2301a24-7806-45b7-8efb-93211b5745bb" />

  -  Hàm dùng để tính số ngày mà một độc giả đã mượn sách.

Khai thác hàm:
  ```sql
  SELECT dbo.fn_TinhSoNgayMuon('2024-01-01','2026-01-20') AS SoNgayMuon;
```
  <img width="1919" height="1079" alt="Screenshot 2026-05-02 101235" src="https://github.com/user-attachments/assets/3d5e8dae-0632-4352-895d-62a3710ceaaa" />


  - Kết quả trả về 750, tức là cuốn sách được mượn trong 750 ngày.

 4.  Table-Valued Function( Danh sách sách còn hàng):
```sql
        CREATE FUNCTION fn_SachConLai()
        RETURNS TABLE
        AS
        RETURN
        (
            SELECT [SachId],[TenSach],[GiaTien],[SoLuong]
            FROM [Sach]
            WHERE [SoLuong] > 0
        );
        GO
```

   <img width="1919" height="1079" alt="Screenshot 2026-05-02 101744" src="https://github.com/user-attachments/assets/fdcee4fa-48b4-457b-92ac-1d6e3f5a75a8" />

  - Hàm này lọc ra những cuốn sách hiện vẫn còn trong kho để có thể cho mượn.

```sql
SELECT * FROM dbo.fn_SachConHang();
```
  - Chỉ những sách có số lượng lớn hơn 0 được hiển thị, thư viện biết sách nào còn để phục vụ độc giả.

  5.  Multi-statement Table-Valued Function( Độc giả mượn nhiều sách):
```sql
CREATE FUNCTION fn_DocGiaMuonNhieu(@SoLan INT)
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
GO
```
<img width="1919" height="1079" alt="Screenshot 2026-05-02 101816" src="https://github.com/user-attachments/assets/1dfdb51b-9be6-4332-ae59-64a62c7cff69" />

   - Lệnh SQL này tìm những độc giả thường xuyên mượn sách nhiều hơn số lần quy định.
```sql
     SELECT * FROM dbo.fn_DocGiaMuonNhieu(2);
```
  - Kết quả: cho thấy những độc giả mượn trên 2 lần


## Phần 3: Xây dựng Store Procedure

1. System Store Procedure
   - sp_help – dùng để xem thông tin tổng quát của một đối tượng
   - sp_helptext – dùng để xem nội dung code của procedure/function/view/trigger
   - sp_helpdb – dùng để xem thông tin các database
   - sp_rename – dùng để đổi tên object

2. Store Procedure để thực hiện lệnh INSERT hoặc UPDATE dữ liệu( Thêm sách):
 ```sql
 CREATE PROCEDURE sp_ThemSach
    @TenSach NVARCHAR(200),
    @Gia MONEY,
    @SoLuong INT
AS
BEGIN
    IF @SoLuong < 0
        PRINT N'Số lượng không hợp lệ'
    ELSE
        INSERT INTO [Sach] VALUES (@TenSach,@Gia,@SoLuong)
END;
GO
```
<img width="1919" height="1079" alt="Screenshot 2026-05-02 102040" src="https://github.com/user-attachments/assets/87b5a8d1-e4aa-4d4d-a356-900c5b7ef888" />

 - Lệnh SQL này tạo thủ tục thêm sách mới nhưng có kiểm tra dữ liệu trước khi thêm. Nếu số lượng âm thì không cho thêm, nếu hợp lệ thì thêm vào bảng Sach.

3. Store Procedure sử dụng tham số OUTPUT( Tính tổng sách)
```sql
CREATE PROCEDURE sp_TongSach
    @Tong INT OUTPUT
AS
BEGIN
    SELECT @Tong = SUM([SoLuong]) FROM [Sach];
END;
GO
```
<img width="1919" height="1079" alt="Screenshot 2026-05-02 102052" src="https://github.com/user-attachments/assets/b31de7fd-4b79-4bcb-8751-29218ade1ab8" />

```sql
DECLARE @KQ INT;
EXEC sp_TongSach @KQ OUTPUT;
PRINT @KQ;
```
  - Kết quả: trả về tổng số lượng sách đang có trong thư viện

4. Store Procedure join nhiều bảng( danh sách mượn)

```sql
CREATE PROCEDURE sp_DanhSachMuon
AS
BEGIN
    SELECT d.TenDocGia, s.TenSach, m.NgayMuon
    FROM [MuonSach] m
    JOIN [DocGia] d ON m.DocGiaId = d.DocGiaId
    JOIN [Sach] s ON m.SachId = s.SachId;
END;
GO
```
<img width="1919" height="1079" alt="Screenshot 2026-05-02 102148" src="https://github.com/user-attachments/assets/c26c908a-c9ce-4a2b-95fc-b860be252958" />

  - Kết quả: cho ra danh sách đầy đủ ai mượn sách gì vào ngày nào.

## Phần 4: Trigger và Xử lý logic nghiệp vụ

1. Trigger giảm số lượng sách khi mượn
```sql
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
GO
```
<img width="1919" height="1079" alt="Screenshot 2026-05-02 102207" src="https://github.com/user-attachments/assets/4d895e8a-1b50-4693-b69b-ec7ba138674e" />

 - Khi có phiếu mượn mới, số lượng sách trong kho sẽ tự động giảm 1.
 - Hệ thống tự động cập nhật kho mà không cần người dùng tự sửa.

2. Test Trigger:
   * Tạo bảng:
  ```sql
     CREATE TABLE [BangA] (
    [Id] INT PRIMARY KEY,
    [GiaTri] INT
);

CREATE TABLE [BangB] (
    [Id] INT PRIMARY KEY,
    [GiaTri] INT
);
GO
```
<img width="1919" height="1079" alt="Screenshot 2026-05-02 102732" src="https://github.com/user-attachments/assets/bb852888-87dd-426b-82d9-660de80bd4b7" />

  - Tạo ra hai bảng đơn giản để mô phỏng việc đồng bộ dữ liệu giữa hai nơi:
    
      Id: khóa chính định danh bản ghi.
    
      GiaTri: giá trị dữ liệu cần đồng bộ

    * Trigger ở bảng A: khi insert thì cập nhật B
```sql
      CREATE TRIGGER trg_A_Update_B
ON [BangA]
AFTER UPDATE
AS
BEGIN
    UPDATE B
    SET B.GiaTri = i.GiaTri
    FROM [BangB] B
    JOIN inserted i ON B.Id = i.Id;
END;
```
<img width="1919" height="1079" alt="Screenshot 2026-05-02 150602" src="https://github.com/user-attachments/assets/84c660e2-64ce-4c16-80de-796d8d2e0d90" />

  - Khi thêm dữ liệu mới vào bảng A:
    
     + Trigger tự động chạy
      
     + Lấy dữ liệu vừa thêm
      
     + Chèn sang bảng B.
   
    

    * Trigger ở bảng B: khi insert thì cập nhật ngược lại A
  ```sql
CREATE TRIGGER trg_B_Update_A
ON [BangB]
AFTER UPDATE
AS
BEGIN
    UPDATE A
    SET A.GiaTri = i.GiaTri
    FROM [BangA] A
    JOIN inserted i ON A.Id = i.Id;
END;
```
<img width="1919" height="1079" alt="Screenshot 2026-05-02 102732" src="https://github.com/user-attachments/assets/f0783ac8-2d43-48ab-b17d-7e67c580ad07" />


  - Khi BangB có dữ liệu mới, tự động truyền tải sang BangA

    *  Thử insert vào
  ```sql
INSERT INTO [BangA] VALUES (1, 10);
INSERT INTO [BangB] VALUES (1, 20);
```
<img width="1919" height="1079" alt="Screenshot 2026-05-02 102746" src="https://github.com/user-attachments/assets/71aa1a9b-6376-4ccc-943e-88da29256e66" />

  * Kiểm tra:
```sql
UPDATE [BangA]
SET GiaTri = 100
WHERE Id = 1;
```
<img width="1919" height="1079" alt="Screenshot 2026-05-02 102805" src="https://github.com/user-attachments/assets/83f35e9e-de99-4f18-9225-5e43e319ad29" />

  → Xuất hiện lỗi vòng lặp
  
  
  →  Việc thiết kế trigger ở bảng A và bảng B cùng tự động cập nhật lẫn nhau là không hợp lý vì sẽ tạo ra hiện tượng đệ quy vô hạn. SQL Server sẽ phát hiện số lần gọi trigger vượt quá giới hạn cho phép và sinh lỗi. Do đó khi xây dựng trigger trong thực tế cần thêm điều kiện kiểm tra hoặc chỉ cho phép đồng bộ một chiều để tránh vòng lặp trigger.

## Phần 5: Cursor và Duyệt dữ liệu

1. Sử dụng Cursor:
```sql
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
```
<img width="1919" height="1079" alt="Screenshot 2026-05-02 151804" src="https://github.com/user-attachments/assets/4095b5d5-866c-4d3d-a61b-b2b4d0f5455e" />

  - Lệnh đã duyệt từng cuốn sách một để kiểm tra sách nào đã hết.
  - Nếu số lượng =0 thì in ra tên sách hết hàng.

2. Không dung Cursor
```sql
   SELECT TenSach
FROM [Sach]
WHERE SoLuong = 0;
```
   <img width="1919" height="1079" alt="Screenshot 2026-05-02 104104" src="https://github.com/user-attachments/assets/ce4492ab-1bb2-43b6-938a-81404f54f183" />

   - Cho cùng kết quả nhưng SQL xử lý nhanh hơn vì làm trên tập dữ liệu thay vì từng dòng.

3. Nhận xét

 - Cursor xử lý từng dòng nên chậm hơn
  
 - SQL thuần tối ưu hơn trong đa số trường hợp

 - Cursor chỉ nên dùng khi cần xử lý logic riêng từng bản ghi



# Kết Luận
Qua bài thực hành xây dựng cơ sở dữ liệu Quản lý thư viện trên SQL Server, em đã áp dụng được các kiến thức quan trọng như thiết kế database, tạo bảng có khóa chính, khóa ngoại và ràng buộc kiểm tra dữ liệu.


Bên cạnh đó, em đã xây dựng được các loại Function, Stored Procedure, Trigger và Cursor để xử lý các yêu cầu nghiệp vụ như tính số ngày mượn, lọc sách còn hàng, thêm dữ liệu, thống kê, tự động cập nhật số lượng sách và duyệt dữ liệu từng dòng. Qua quá trình thực hiện, em nhận thấy mỗi đối tượng trong SQL Server đều có vai trò riêng và hỗ trợ rất tốt cho việc quản lý dữ liệu.


Đặc biệt, bài làm giúp em hiểu rõ hơn về tính toàn vẹn dữ liệu, khả năng tự động hóa xử lý và sự khác nhau giữa cách xử lý tuần tự bằng Cursor với cách xử lý theo tập dữ liệu của SQL. Đây là nền tảng quan trọng để em củng cố kỹ năng làm việc với hệ quản trị cơ sở dữ liệu trong thực tế.


    



   




