
/****** Object:  Database [QLDT]    Script Date: 20/04/2023 14:41:36 ******/
CREATE DATABASE [QLDT]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'QLDT', FILENAME = N'D:\QLDT.mdf' , SIZE = 3072KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'QLDT_log', FILENAME = N'D:\QLDT_log.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [QLDT] SET COMPATIBILITY_LEVEL = 120
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [QLDT].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [QLDT] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [QLDT] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [QLDT] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [QLDT] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [QLDT] SET ARITHABORT OFF 
GO
ALTER DATABASE [QLDT] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [QLDT] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [QLDT] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [QLDT] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [QLDT] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [QLDT] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [QLDT] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [QLDT] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [QLDT] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [QLDT] SET  DISABLE_BROKER 
GO
ALTER DATABASE [QLDT] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [QLDT] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [QLDT] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [QLDT] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [QLDT] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [QLDT] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [QLDT] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [QLDT] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [QLDT] SET  MULTI_USER 
GO
ALTER DATABASE [QLDT] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [QLDT] SET DB_CHAINING OFF 
GO
ALTER DATABASE [QLDT] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [QLDT] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE [QLDT] SET DELAYED_DURABILITY = DISABLED 
GO
USE [QLDT]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_ds_mon_se_hoc]    Script Date: 20/04/2023 14:41:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Do Duy Cop
-- Create date: 20.4.23
-- Description:	tao ds mon cua 1 sv se hoc
-- =============================================
CREATE FUNCTION [DBO].[FN_DS_MON_SE_HOC]
(
	@masv varchar(13),
	@n int =2  -- số môn tối đa trong 1 đợt mà sv đc phép học cùng lúc
)
RETURNS 
@KQ TABLE
(
	mamon varchar(7)
)
AS
BEGIN
	with T as(
		select distinct H.MaMon,  C.STT
		from HocTap H join SV S on (H.masv=S.masv)and(S.masv=@masv)and(H.maTT=1 or H.maTT=5)
		              join Nganh N on N.maNganh=S.maNganh
					  join ChiTiet C on (C.manganh=N.maNganh)and(C.mamon=H.maMon)
	)
	insert into @KQ(mamon)
		select top (@n) maMon 
		from T 
		order by T.STT;	
	
	RETURN 
END

GO
/****** Object:  UserDefinedFunction [dbo].[fn_ds_sv_se_hoc]    Script Date: 20/04/2023 14:41:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Do Duy Cop
-- Create date: 20.4.23
-- Description:	tao ds mon cua 1 sv se hoc
-- =============================================
CREATE FUNCTION [DBO].[FN_DS_SV_SE_HOC]
(
	@maMon varchar(7),
	@n int
)
RETURNS 
@KQ TABLE
(
	masv varchar(13)
)
AS
BEGIN
	with T as(
		select S.masv, H.MaMon, C.STT
		from HocTap H join SV S on H.masv=S.masv and H.maMon=@maMon
					join Nganh N on N.maNganh=S.maNganh
					join ChiTiet C on C.manganh=N.maNganh and C.mamon=H.maMon
		where (H.maTT=1 or H.maTT=5)
			and(H.maMon in (select maMon from DBO.FN_DS_MON_SE_HOC(S.masv,@n)))
	)
	insert into @KQ(masv)
		select masv
		from T
		order by T.STT;

	RETURN 
END

GO
/****** Object:  Table [dbo].[ChiTiet]    Script Date: 20/04/2023 14:41:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ChiTiet](
	[manganh] [int] NOT NULL,
	[mamon] [varchar](7) NOT NULL,
	[STT] [int] NULL,
 CONSTRAINT [PK_ChiTiet] PRIMARY KEY CLUSTERED 
(
	[manganh] ASC,
	[mamon] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Dot]    Script Date: 20/04/2023 14:41:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Dot](
	[maDot] [char](5) NOT NULL,
	[TuNgay] [date] NULL,
	[DenNgay] [date] NULL,
 CONSTRAINT [PK_Dot] PRIMARY KEY CLUSTERED 
(
	[maDot] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[HocTap]    Script Date: 20/04/2023 14:41:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[HocTap](
	[masv] [varchar](13) NOT NULL,
	[maMon] [varchar](7) NOT NULL,
	[maTT] [int] NOT NULL CONSTRAINT [DF_HocTap_maTT]  DEFAULT ((1)),
	[Diem] [float] NULL,
 CONSTRAINT [PK_HocTap] PRIMARY KEY CLUSTERED 
(
	[masv] ASC,
	[maMon] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Lop]    Script Date: 20/04/2023 14:41:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Lop](
	[maLop] [int] IDENTITY(1,1) NOT NULL,
	[maMon] [varchar](7) NULL,
	[maDot] [char](5) NULL,
	[SL] [int] NULL,
 CONSTRAINT [PK_Lop] PRIMARY KEY CLUSTERED 
(
	[maLop] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MonHoc]    Script Date: 20/04/2023 14:41:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MonHoc](
	[maMon] [varchar](7) NOT NULL,
	[tenMon] [nvarchar](50) NULL,
	[STC] [int] NULL,
 CONSTRAINT [PK_MonHoc] PRIMARY KEY CLUSTERED 
(
	[maMon] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Nganh]    Script Date: 20/04/2023 14:41:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Nganh](
	[maNganh] [int] NOT NULL,
	[tenNganh] [nvarchar](500) NULL,
 CONSTRAINT [PK_Nganh] PRIMARY KEY CLUSTERED 
(
	[maNganh] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SV]    Script Date: 20/04/2023 14:41:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SV](
	[masv] [varchar](13) NOT NULL,
	[họten] [nvarchar](50) NULL,
	[ngaysinh] [date] NULL,
	[GT] [bit] NULL,
	[maNganh] [int] NULL,
	[maDot] [char](5) NULL,
 CONSTRAINT [PK_SV] PRIMARY KEY CLUSTERED 
(
	[masv] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TrangThai]    Script Date: 20/04/2023 14:41:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TrangThai](
	[maTT] [int] NOT NULL,
	[tenTT] [nvarchar](50) NULL,
 CONSTRAINT [PK_TrangThai] PRIMARY KEY CLUSTERED 
(
	[maTT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
INSERT [dbo].[ChiTiet] ([manganh], [mamon], [STT]) VALUES (1, N'mon0001', 1)
GO
INSERT [dbo].[ChiTiet] ([manganh], [mamon], [STT]) VALUES (1, N'mon0002', 2)
GO
INSERT [dbo].[ChiTiet] ([manganh], [mamon], [STT]) VALUES (1, N'mon0003', 3)
GO
INSERT [dbo].[ChiTiet] ([manganh], [mamon], [STT]) VALUES (1, N'mon0004', 4)
GO
INSERT [dbo].[ChiTiet] ([manganh], [mamon], [STT]) VALUES (2, N'mon0001', 1)
GO
INSERT [dbo].[ChiTiet] ([manganh], [mamon], [STT]) VALUES (2, N'mon0002', 2)
GO
INSERT [dbo].[ChiTiet] ([manganh], [mamon], [STT]) VALUES (2, N'mon0003', 3)
GO
INSERT [dbo].[ChiTiet] ([manganh], [mamon], [STT]) VALUES (2, N'mon0005', 4)
GO
INSERT [dbo].[ChiTiet] ([manganh], [mamon], [STT]) VALUES (3, N'mon0001', 1)
GO
INSERT [dbo].[ChiTiet] ([manganh], [mamon], [STT]) VALUES (3, N'mon0002', 2)
GO
INSERT [dbo].[ChiTiet] ([manganh], [mamon], [STT]) VALUES (3, N'mon0003', 3)
GO
INSERT [dbo].[ChiTiet] ([manganh], [mamon], [STT]) VALUES (3, N'mon0006', 4)
GO
INSERT [dbo].[ChiTiet] ([manganh], [mamon], [STT]) VALUES (3, N'mon0007', 5)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv1', N'mon0001', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv1', N'mon0002', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv1', N'mon0003', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv1', N'mon0004', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv10', N'mon0001', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv10', N'mon0002', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv10', N'mon0003', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv10', N'mon0004', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv10', N'mon0005', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv10', N'mon0006', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv10', N'mon0007', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv10', N'mon0008', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv10', N'mon0009', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv10', N'mon0010', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv2', N'mon0001', 2, 8)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv2', N'mon0002', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv2', N'mon0003', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv2', N'mon0004', 2, 7)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv2', N'mon0005', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv2', N'mon0006', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv2', N'mon0007', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv2', N'mon0008', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv2', N'mon0009', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv2', N'mon0010', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv3', N'mon0001', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv3', N'mon0002', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv3', N'mon0003', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv3', N'mon0004', 2, 6)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv3', N'mon0005', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv3', N'mon0006', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv3', N'mon0007', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv4', N'mon0001', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv4', N'mon0002', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv4', N'mon0003', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv4', N'mon0004', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv5', N'mon0001', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv5', N'mon0002', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv5', N'mon0003', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv5', N'mon0004', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv5', N'mon0005', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv5', N'mon0007', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv5', N'mon0008', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv5', N'mon0009', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv5', N'mon0010', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv6', N'mon0001', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv6', N'mon0002', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv6', N'mon0003', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv6', N'mon0004', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv6', N'mon0005', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv6', N'mon0006', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv6', N'mon0007', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv6', N'mon0008', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv6', N'mon0009', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv6', N'mon0010', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv7', N'mon0001', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv7', N'mon0002', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv7', N'mon0003', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv7', N'mon0004', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv7', N'mon0005', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv7', N'mon0006', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv7', N'mon0007', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv7', N'mon0008', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv7', N'mon0009', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv7', N'mon0010', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv8', N'mon0001', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv8', N'mon0002', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv8', N'mon0003', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv8', N'mon0004', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv8', N'mon0005', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv8', N'mon0006', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv8', N'mon0007', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv8', N'mon0008', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv8', N'mon0009', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv8', N'mon0010', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv9', N'mon0001', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv9', N'mon0002', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv9', N'mon0003', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv9', N'mon0004', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv9', N'mon0005', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv9', N'mon0006', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv9', N'mon0007', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv9', N'mon0008', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv9', N'mon0009', 1, NULL)
GO
INSERT [dbo].[HocTap] ([masv], [maMon], [maTT], [Diem]) VALUES (N'sv9', N'mon0010', 1, NULL)
GO
SET IDENTITY_INSERT [dbo].[Lop] ON 

GO
INSERT [dbo].[Lop] ([maLop], [maMon], [maDot], [SL]) VALUES (1, N'mon0002', N'20231', 10)
GO
INSERT [dbo].[Lop] ([maLop], [maMon], [maDot], [SL]) VALUES (2, N'mon0003', N'20231', 10)
GO
INSERT [dbo].[Lop] ([maLop], [maMon], [maDot], [SL]) VALUES (3, N'mon0001', N'20231', 9)
GO
SET IDENTITY_INSERT [dbo].[Lop] OFF
GO
INSERT [dbo].[MonHoc] ([maMon], [tenMon], [STC]) VALUES (N'mon0001', N'A', 2)
GO
INSERT [dbo].[MonHoc] ([maMon], [tenMon], [STC]) VALUES (N'mon0002', N'B', 2)
GO
INSERT [dbo].[MonHoc] ([maMon], [tenMon], [STC]) VALUES (N'mon0003', N'C', 3)
GO
INSERT [dbo].[MonHoc] ([maMon], [tenMon], [STC]) VALUES (N'mon0004', N'D', 3)
GO
INSERT [dbo].[MonHoc] ([maMon], [tenMon], [STC]) VALUES (N'mon0005', N'E', 4)
GO
INSERT [dbo].[MonHoc] ([maMon], [tenMon], [STC]) VALUES (N'mon0006', N'F', 4)
GO
INSERT [dbo].[MonHoc] ([maMon], [tenMon], [STC]) VALUES (N'mon0007', N'G', 5)
GO
INSERT [dbo].[MonHoc] ([maMon], [tenMon], [STC]) VALUES (N'mon0008', N'H', 2)
GO
INSERT [dbo].[MonHoc] ([maMon], [tenMon], [STC]) VALUES (N'mon0009', N'X', 3)
GO
INSERT [dbo].[MonHoc] ([maMon], [tenMon], [STC]) VALUES (N'mon0010', N'Z', 3)
GO
INSERT [dbo].[Nganh] ([maNganh], [tenNganh]) VALUES (1, N'Kỹ thuật Điện dân dụng')
GO
INSERT [dbo].[Nganh] ([maNganh], [tenNganh]) VALUES (2, N'Kỹ thuật Xây Dựng')
GO
INSERT [dbo].[Nganh] ([maNganh], [tenNganh]) VALUES (3, N'Kỹ thuật máy tính')
GO
INSERT [dbo].[SV] ([masv], [họten], [ngaysinh], [GT], [maNganh], [maDot]) VALUES (N'sv1', N'x1', NULL, NULL, 1, NULL)
GO
INSERT [dbo].[SV] ([masv], [họten], [ngaysinh], [GT], [maNganh], [maDot]) VALUES (N'sv10', N'x10', NULL, NULL, 3, NULL)
GO
INSERT [dbo].[SV] ([masv], [họten], [ngaysinh], [GT], [maNganh], [maDot]) VALUES (N'sv2', N'x2', NULL, NULL, 1, NULL)
GO
INSERT [dbo].[SV] ([masv], [họten], [ngaysinh], [GT], [maNganh], [maDot]) VALUES (N'sv3', N'x3', NULL, NULL, 1, NULL)
GO
INSERT [dbo].[SV] ([masv], [họten], [ngaysinh], [GT], [maNganh], [maDot]) VALUES (N'sv4', N'x4', NULL, NULL, 1, NULL)
GO
INSERT [dbo].[SV] ([masv], [họten], [ngaysinh], [GT], [maNganh], [maDot]) VALUES (N'sv5', N'x5', NULL, NULL, 2, NULL)
GO
INSERT [dbo].[SV] ([masv], [họten], [ngaysinh], [GT], [maNganh], [maDot]) VALUES (N'sv6', N'x6', NULL, NULL, 2, NULL)
GO
INSERT [dbo].[SV] ([masv], [họten], [ngaysinh], [GT], [maNganh], [maDot]) VALUES (N'sv7', N'x7', NULL, NULL, 2, NULL)
GO
INSERT [dbo].[SV] ([masv], [họten], [ngaysinh], [GT], [maNganh], [maDot]) VALUES (N'sv8', N'x8', NULL, NULL, 2, NULL)
GO
INSERT [dbo].[SV] ([masv], [họten], [ngaysinh], [GT], [maNganh], [maDot]) VALUES (N'sv9', N'x9', NULL, NULL, 3, NULL)
GO
INSERT [dbo].[TrangThai] ([maTT], [tenTT]) VALUES (1, N'Chưa học, Phải học')
GO
INSERT [dbo].[TrangThai] ([maTT], [tenTT]) VALUES (2, N'Đã Quy Đổi điểm')
GO
INSERT [dbo].[TrangThai] ([maTT], [tenTT]) VALUES (3, N'Đang học')
GO
INSERT [dbo].[TrangThai] ([maTT], [tenTT]) VALUES (4, N'Đạt')
GO
INSERT [dbo].[TrangThai] ([maTT], [tenTT]) VALUES (5, N'Không Đạt, Cần học lại')
GO
ALTER TABLE [dbo].[ChiTiet]  WITH CHECK ADD  CONSTRAINT [FK_ChiTiet_MonHoc] FOREIGN KEY([mamon])
REFERENCES [dbo].[MonHoc] ([maMon])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[ChiTiet] CHECK CONSTRAINT [FK_ChiTiet_MonHoc]
GO
ALTER TABLE [dbo].[ChiTiet]  WITH CHECK ADD  CONSTRAINT [FK_ChiTiet_Nganh] FOREIGN KEY([manganh])
REFERENCES [dbo].[Nganh] ([maNganh])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[ChiTiet] CHECK CONSTRAINT [FK_ChiTiet_Nganh]
GO
ALTER TABLE [dbo].[HocTap]  WITH CHECK ADD  CONSTRAINT [FK_HocTap_MonHoc] FOREIGN KEY([maMon])
REFERENCES [dbo].[MonHoc] ([maMon])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[HocTap] CHECK CONSTRAINT [FK_HocTap_MonHoc]
GO
ALTER TABLE [dbo].[HocTap]  WITH CHECK ADD  CONSTRAINT [FK_HocTap_SV] FOREIGN KEY([masv])
REFERENCES [dbo].[SV] ([masv])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[HocTap] CHECK CONSTRAINT [FK_HocTap_SV]
GO
ALTER TABLE [dbo].[HocTap]  WITH CHECK ADD  CONSTRAINT [FK_HocTap_TrangThai] FOREIGN KEY([maTT])
REFERENCES [dbo].[TrangThai] ([maTT])
GO
ALTER TABLE [dbo].[HocTap] CHECK CONSTRAINT [FK_HocTap_TrangThai]
GO
ALTER TABLE [dbo].[SV]  WITH CHECK ADD  CONSTRAINT [FK_SV_Nganh] FOREIGN KEY([maNganh])
REFERENCES [dbo].[Nganh] ([maNganh])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[SV] CHECK CONSTRAINT [FK_SV_Nganh]
GO
ALTER TABLE [dbo].[SV]  WITH CHECK ADD  CONSTRAINT [FK_SV_SV] FOREIGN KEY([maDot])
REFERENCES [dbo].[Dot] ([maDot])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[SV] CHECK CONSTRAINT [FK_SV_SV]
GO
/****** Object:  StoredProcedure [dbo].[SP_MoLop]    Script Date: 20/04/2023 14:41:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Do Duy Cop
-- Create date: 20.4.23
-- Description:	ds lop se mo -> $$$
-- =============================================
CREATE PROCEDURE [dbo].[SP_MoLop]
    @action nvarchar(50),
	@MinSL int= 20,
	@MaxLop int =4,
	@maDot char(5)=null
AS
BEGIN
	if(@action='List_Lop')
	begin
		with T as (
			select H.MaMon,count(H.maMon) as SL
			from HocTap H join SV S on H.masv=S.masv
			where (H.maTT=1 or H.maTT=5)
				  AND H.MaMon in (select mamon from DBO.FN_DS_MON_SE_HOC(S.masv,@MaxLop))
			group by H.MaMon
			having count(*)>=@MinSL
		)

		select M.mamon as [Mã môn],
			   M.tenMon as [Tên môn],
			   M.STC,
			   T.SL  as [Sĩ Số lớp]
		from T join MonHoc M on T.maMon=M.maMon
		order by SL desc;
	end
	else if(@action='Mo_Lop')
	begin
		with T as(
			select H.MaMon,count(H.maMon) as SL
			from HocTap H join SV S on H.masv=S.masv
			where (H.maTT=1 or H.maTT=5)
				  AND H.MaMon in (select mamon from DBO.FN_DS_MON_SE_HOC(S.masv,@MaxLop))
			group by H.MaMon
			having count(*)>=@minSL
		)
		insert into Lop(MaMon,MaDot,SL)
		select T.maMon,@maDot,T.SL
		from T 
		where MaMon not in (select MaMon From Lop where maDot=@maDot)
		order by T.SL desc;

		--with T as(
		--	select H.MaMon,count(H.maMon) as SL
		--	from HocTap H join SV S on H.masv=S.masv
		--	where (H.maTT=1 or H.maTT=5)
		--		  AND H.MaMon in (select mamon from DBO.fn_ds_mon_se_hoc(S.masv,@MaxLop))
		--	group by H.MaMon
		--	having count(*)>=@minSL
		--)
		--insert into Lop(MaMon,MaDot)
		--select MaMon,@MaDot
		--From T;
	end
END

GO
USE [master]
GO
ALTER DATABASE [QLDT] SET  READ_WRITE 
GO
