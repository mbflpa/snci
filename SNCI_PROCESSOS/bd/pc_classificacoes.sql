SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[pc_classificacoes](
	[pc_class_id] [int] IDENTITY(1,1) NOT NULL,
	[pc_class_descricao] [varchar](100) NOT NULL,
	[pc_class_status] [varchar](1) NOT NULL,
	[pc_class_comentario] [varchar](max) NULL,
 CONSTRAINT [PK_pc_classificacoes] PRIMARY KEY CLUSTERED 
(
	[pc_class_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
