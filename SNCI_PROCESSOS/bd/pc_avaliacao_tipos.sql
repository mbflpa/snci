SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[pc_avaliacao_tipos](
	[pc_aval_tipo_id] [int] IDENTITY(1,1) NOT NULL,
	[pc_aval_tipo_descricao] [varchar](200) NULL,
	[pc_aval_tipo_status] [varchar](1) NOT NULL,
	[pc_aval_tipo_comentario] [varchar](1000) NULL,
	[pc_aval_tipo_macroprocessos] [varchar](250) NULL,
	[pc_aval_tipo_processoN1] [varchar](250) NULL,
	[pc_aval_tipo_processoN2] [varchar](250) NULL,
	[pc_aval_tipo_processoN3] [varchar](250) NULL,
 CONSTRAINT [PK_pc_avaliacao_tipos] PRIMARY KEY CLUSTERED 
(
	[pc_aval_tipo_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
