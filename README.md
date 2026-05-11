# BÀI KIỂM TRA SỐ 3 – HỆ QUẢN TRỊ CSDL

# Thông tin sinh viên

- Họ tên: NGUYỄN DUY
- Mã SV: K235480106102
- Chủ đề: Quản lý các hợp đồng vay tiền thế chấp tài sản

## Tạo database và các bảng
  - Tạo database:

```sql
CREATE DATABASE QLHDVT;
GO

USE QLHDVT;
GO
```
<img width="1919" height="1079" alt="Screenshot 2026-05-11 001735" src="https://github.com/user-attachments/assets/1e98f3de-9ef8-4473-9bcb-e51c2ccd266a" />

  -  Tạo các bảng:

```sql

CREATE TABLE Customers (
    CustomerID INT IDENTITY PRIMARY KEY,
    FullName NVARCHAR(100),
    Phone VARCHAR(15),
    CreatedAt DATETIME DEFAULT GETDATE()
);

CREATE TABLE Contracts (
    ContractID INT IDENTITY PRIMARY KEY,
    CustomerID INT,
    Principal MONEY,
    StartDate DATE,
    Deadline1 DATE,
    Deadline2 DATE,
    Status NVARCHAR(50),

    FOREIGN KEY (CustomerID)
    REFERENCES Customers(CustomerID)
);

CREATE TABLE Assets (
    AssetID INT IDENTITY PRIMARY KEY,
    ContractID INT,
    AssetName NVARCHAR(100),
    Value MONEY,
    Status NVARCHAR(50),

    FOREIGN KEY (ContractID)
    REFERENCES Contracts(ContractID)
);

CREATE TABLE Payments (
    PaymentID INT IDENTITY PRIMARY KEY,
    ContractID INT,
    Amount MONEY,
    PaymentDate DATETIME DEFAULT GETDATE(),
    Collector NVARCHAR(100),

    FOREIGN KEY (ContractID)
    REFERENCES Contracts(ContractID)
);

CREATE TABLE AuditLogs (
    LogID INT IDENTITY PRIMARY KEY,
    ContractID INT,
    Action NVARCHAR(100),
    Amount MONEY,
    CreatedAt DATETIME DEFAULT GETDATE(),
    Note NVARCHAR(255)
);

GO
```
<img width="1919" height="1079" alt="Screenshot 2026-05-11 002006" src="https://github.com/user-attachments/assets/3c0226bd-5bb9-4a2f-ba7e-b31ff9964740" />

## Event 1. ĐĂNG KÝ HỢP ĐỒNG MỚI
  -  Tạo Stored Procedure

```sql
GO

CREATE PROCEDURE sp_CreateContract
(
    @FullName NVARCHAR(100),
    @Phone VARCHAR(15),
    @Principal MONEY
)
AS
BEGIN

    INSERT INTO Customers
    (
        FullName,
        Phone
    )
    VALUES
    (
        @FullName,
        @Phone
    );

    DECLARE @CustomerID INT;

    SET @CustomerID = SCOPE_IDENTITY();

    INSERT INTO Contracts
    (
        CustomerID,
        Principal,
        StartDate,
        Deadline1,
        Deadline2,
        Status
    )
    VALUES
    (
        @CustomerID,
        @Principal,
        GETDATE(),
        DATEADD(DAY, 5, GETDATE()),
        DATEADD(DAY, 10, GETDATE()),
        N'Đang vay'
    );

END;
GO
```
<img width="1919" height="1079" alt="Screenshot 2026-05-11 002848" src="https://github.com/user-attachments/assets/f777786b-f1b3-4130-9840-0752a5bbf98d" />


  -  Test event 1:

```sql

EXEC sp_CreateContract
    N'Nguyen Van A',
    '0123456789',
    10000000;
```
<img width="1919" height="1079" alt="Screenshot 2026-05-11 002858" src="https://github.com/user-attachments/assets/ce0d0686-f229-4808-88d6-fc2d96137317" />

  -  Thêm tài sản:

```sql
INSERT INTO Assets
(
    ContractID,
    AssetName,
    Value,
    Status
)
VALUES
(1, N'Iphone 15', 7000000, N'Đang cầm cố'),

(1, N'Xe máy Honda', 15000000, N'Đang cầm cố');
```
<img width="1919" height="1079" alt="Screenshot 2026-05-11 003036" src="https://github.com/user-attachments/assets/bf50c9d1-48bd-4a21-85e4-af2d83a88338" />

  -  Kiểm tra kết quả

```sql
SELECT * FROM Customers;

SELECT * FROM Contracts;

SELECT * FROM Assets;
```
<img width="1919" height="1079" alt="Screenshot 2026-05-11 003054" src="https://github.com/user-attachments/assets/264b45d0-ca9f-48bb-9a47-d105c2bd4351" />

  * Tổng kết event 1:

-Tạo khách hàng và hợp đồng vay mới.

-Thêm tài sản cầm cố cho hợp đồng.

-Kiểm tra dữ liệu đã được lưu thành công.

## Event 2. TÍNH TOÁN CÔNG NỢ
  -  Tạo Function:

```sql
GO

CREATE FUNCTION fn_CalcMoneyContract
(
    @ContractID INT,
    @TargetDate DATE
)
RETURNS MONEY
AS
BEGIN

    DECLARE @Principal MONEY;
    DECLARE @StartDate DATE;
    DECLARE @Deadline1 DATE;

    SELECT
        @Principal = Principal,
        @StartDate = StartDate,
        @Deadline1 = Deadline1
    FROM Contracts
    WHERE ContractID = @ContractID;

    DECLARE @Days1 INT =
        CASE
            WHEN @TargetDate <= @Deadline1
            THEN DATEDIFF(DAY, @StartDate, @TargetDate)

            ELSE DATEDIFF(DAY, @StartDate, @Deadline1)
        END;

    DECLARE @SimpleInterest MONEY =
        @Principal * 0.005 * @Days1;

    IF @TargetDate <= @Deadline1
        RETURN @Principal + @SimpleInterest;

    DECLARE @Days2 INT =
        DATEDIFF(DAY, @Deadline1, @TargetDate);

    DECLARE @Amount MONEY =
        @Principal + @SimpleInterest;

    SET @Amount =
        @Amount * POWER(1.005, @Days2);

    RETURN @Amount;

END;
GO
```
<img width="1919" height="1079" alt="Screenshot 2026-05-11 003113" src="https://github.com/user-attachments/assets/d86de751-e5f4-4d45-961c-30151ae43d9e" />

  -  Test Event 2:

```sql

SELECT
    ContractID,

    dbo.fn_CalcMoneyContract
    (
        ContractID,
        GETDATE()
    ) AS TongTienPhaiTra

FROM Contracts;
```
<img width="1919" height="1079" alt="Screenshot 2026-05-11 003155" src="https://github.com/user-attachments/assets/e77e9a85-779b-41ae-bb10-48fab8f11b53" />

  * Tổng kết event 2:

-Tính tổng số tiền khách phải trả.

-Áp dụng lãi đơn và lãi kép theo thời gian.

-Hiển thị công nợ hiện tại của hợp đồng.

## Event 3. XỬ LÝ TRẢ NỢ

  -  Tạo Procedure:

```sql
GO

CREATE PROCEDURE sp_PayDebt
(
    @ContractID INT,
    @Amount MONEY,
    @Collector NVARCHAR(100)
)
AS
BEGIN

    DECLARE @Debt MONEY;

    SET @Debt =
        dbo.fn_CalcMoneyContract
        (
            @ContractID,
            GETDATE()
        );

    INSERT INTO Payments
    (
        ContractID,
        Amount,
        Collector
    )
    VALUES
    (
        @ContractID,
        @Amount,
        @Collector
    );

    SET @Debt = @Debt - @Amount;

    IF @Debt <= 0
    BEGIN

        UPDATE Contracts
        SET Status = N'Đã thanh toán'
        WHERE ContractID = @ContractID;

        UPDATE Assets
        SET Status = N'Đã trả khách'
        WHERE ContractID = @ContractID;

    END

    ELSE
    BEGIN

        UPDATE Contracts
        SET Status = N'Đang trả góp'
        WHERE ContractID = @ContractID;

    END

END;
GO
```
<img width="1919" height="1079" alt="Screenshot 2026-05-11 003212" src="https://github.com/user-attachments/assets/520bd4f7-db72-41fa-9a61-3c5352aa1bba" />

  -  Test Event 3:

```sql

EXEC sp_PayDebt
    1,
    2000000,
    N'Admin';
```
<img width="1919" height="1079" alt="Screenshot 2026-05-11 003225" src="https://github.com/user-attachments/assets/a1538dbb-47ad-4e65-af12-11faa00b1c96" />

  -  Kiểm tra kết quả:

```sql
SELECT * FROM Payments;

SELECT * FROM Contracts;

SELECT * FROM Assets;
```
<img width="1919" height="1079" alt="Screenshot 2026-05-11 003259" src="https://github.com/user-attachments/assets/11d0672c-0f24-4a88-88e7-e9445a2a3ea0" />

  * Tổng kết event 3:

-Thực hiện thanh toán cho hợp đồng vay.

-Cập nhật trạng thái hợp đồng sau khi trả tiền.

-Lưu lịch sử thanh toán của khách hàng.


## Event 4. DANH SÁCH NỢ XẤU

  -  Thêm dữ liệu quá hạn:

```sql
INSERT INTO Contracts
(
    CustomerID,
    Principal,
    StartDate,
    Deadline1,
    Deadline2,
    Status
)
VALUES
(
    1,
    5000000,
    DATEADD(DAY, -20, GETDATE()),
    DATEADD(DAY, -10, GETDATE()),
    DATEADD(DAY, -5, GETDATE()),
    N'Quá hạn'
);
```
<img width="1919" height="1079" alt="Screenshot 2026-05-11 003353" src="https://github.com/user-attachments/assets/75bc7433-3cda-4604-b4c5-2f472b0c618a" />

  -  Truy vấn nợ xấu:

```sql

SELECT
    c.FullName,
    c.Phone,
    ct.Principal,

    DATEDIFF
    (
        DAY,
        ct.Deadline1,
        GETDATE()
    ) AS SoNgayQuaHan,

    dbo.fn_CalcMoneyContract
    (
        ct.ContractID,
        GETDATE()
    ) AS TongTienNo

FROM Contracts ct

JOIN Customers c
ON ct.CustomerID = c.CustomerID

WHERE ct.Status = N'Quá hạn';
```
<img width="1919" height="1079" alt="Screenshot 2026-05-11 003417" src="https://github.com/user-attachments/assets/7d468a08-7cd9-4871-865d-bb72eb8ea12f" />

  * Tổng kết event 4:

-Tạo dữ liệu hợp đồng quá hạn.

-Hiển thị khách hàng đang nợ xấu.

-Tính số ngày quá hạn và tổng tiền nợ.

## Event 5. QUẢN LÝ THANH LÝ TÀI SẢN

  -  Trigger chuyển nợ xấu:

```sql
GO

CREATE TRIGGER trg_BadDebt
ON Contracts
AFTER UPDATE
AS
BEGIN

    UPDATE Contracts
    SET Status = N'Quá hạn'
    WHERE
        Deadline1 < GETDATE()
        AND Status = N'Đang vay';

END;
GO
```
<img width="1919" height="1079" alt="Screenshot 2026-05-11 003431" src="https://github.com/user-attachments/assets/7254dd41-8232-45a4-ac8e-e910343cee8e" />

  -  Trigger chuẩn bị thanh lý:

```sql

GO

CREATE TRIGGER trg_PreLiquidation
ON Contracts
AFTER UPDATE
AS
BEGIN

    UPDATE Assets
    SET Status = N'Sẵn sàng thanh lý'
    WHERE ContractID IN
    (
        SELECT ContractID
        FROM Contracts
        WHERE
            Deadline2 < GETDATE()
            AND Status = N'Quá hạn'
    );

END;
GO
```
<img width="1919" height="1079" alt="Screenshot 2026-05-11 003453" src="https://github.com/user-attachments/assets/c4aeb7a6-76cd-47aa-9239-26bc266c2272" />

  -  Trigger bán thanh lý:

```sql
GO

CREATE TRIGGER trg_SoldAssets
ON Contracts
AFTER UPDATE
AS
BEGIN

    UPDATE Assets
    SET Status = N'Đã bán thanh lý'
    WHERE ContractID IN
    (
        SELECT ContractID
        FROM Contracts
        WHERE Status = N'Đã thanh lý'
    );

END;
GO
```
<img width="1919" height="1079" alt="Screenshot 2026-05-11 003715" src="https://github.com/user-attachments/assets/9ee4b8db-6cb7-4563-8a70-802ce56a00e7" />

  -  Test Event 5:

```sql

UPDATE Contracts
SET Status = N'Đã thanh lý'
WHERE ContractID = 2;

SELECT * FROM Assets;
```
<img width="1919" height="1079" alt="Screenshot 2026-05-11 003737" src="https://github.com/user-attachments/assets/9b4fdd76-c480-48bc-bd1d-217684a5a474" />

   * Tổng kết event 5:

-Tự động cập nhật trạng thái hợp đồng quá hạn.

-Chuyển tài sản sang trạng thái thanh lý.

-Kiểm tra kết quả cập nhật tài sản.

## EVENT BỔ SUNG — GIA HẠN HỢP ĐỒNG

  -  Procedure gia hạn:

```sql
GO

CREATE PROCEDURE sp_ExtendContract
(
    @ContractID INT
)
AS
BEGIN

    UPDATE Contracts
    SET
        Deadline1 = DATEADD(DAY, 5, Deadline1),
        Deadline2 = DATEADD(DAY, 5, Deadline2),
        Status = N'Đang vay'

    WHERE ContractID = @ContractID;

END;
GO
```
<img width="1919" height="1079" alt="Screenshot 2026-05-11 003758" src="https://github.com/user-attachments/assets/cc006487-d211-41ab-bab0-f7d2a3e62e71" />

  -  Test gia hạn

```sql

EXEC sp_ExtendContract 1;

SELECT * FROM Contracts;
```
<img width="1919" height="1079" alt="Screenshot 2026-05-11 003810" src="https://github.com/user-attachments/assets/4fe66b78-fe10-4aed-a005-9b14e96a869f" />

  * Tổng kết event:

-Gia hạn thời gian vay cho khách hàng.

-Cập nhật lại các mốc deadline.

-Đưa hợp đồng về trạng thái đang vay.

## EVENT BỔ SUNG — AUDIT LOG

  -  Trigger log thanh toán

```sql
GO

CREATE TRIGGER trg_LogPayment
ON Payments
AFTER INSERT
AS
BEGIN

    INSERT INTO AuditLogs
    (
        ContractID,
        Action,
        Amount,
        Note
    )

    SELECT
        ContractID,
        N'Thanh toán',
        Amount,
        N'Khách trả tiền'

    FROM inserted;

END;
GO
```
<img width="1919" height="1078" alt="Screenshot 2026-05-11 003823" src="https://github.com/user-attachments/assets/14d70613-0d97-4d1d-aaa2-d8e51357b0d1" />

  -  Test Audit Log

```sql

EXEC sp_PayDebt
    1,
    1000000,
    N'Staff';

SELECT * FROM AuditLogs;
```
<img width="1919" height="1079" alt="Screenshot 2026-05-11 003838" src="https://github.com/user-attachments/assets/ab621abf-6d1c-4146-be1f-da96c11b8739" />

  * Tổng kết event:

-Ghi nhận lịch sử giao dịch thanh toán.

-Theo dõi các hoạt động trả nợ của khách.

-Kiểm tra dữ liệu log sau khi thanh toán.
