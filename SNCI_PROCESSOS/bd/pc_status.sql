SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[pc_status](
	[pc_status_id] [int] IDENTITY(1,1) NOT NULL,
	[pc_status_descricao] [varchar](100) NOT NULL,
	[pc_status_status] [varchar](1) NOT NULL,
	[pc_status_comentario] [varchar](max) NULL,
	[pc_status_card_style_body] [varchar](200) NULL,
	[pc_status_card_style_header] [varchar](200) NULL,
	[pc_status_card_style_ribbon] [varchar](200) NULL,
	[pc_status_card_nome_ribbon] [varchar](20) NULL,
 CONSTRAINT [PK_pc_status] PRIMARY KEY CLUSTERED 
(
	[pc_status_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[pc_status] ADD  CONSTRAINT [DF__pc_status__pc_st__5812160E]  DEFAULT ('background:#000;color:#fff;') FOR [pc_status_card_style_body]
GO
ALTER TABLE [dbo].[pc_status] ADD  CONSTRAINT [DF__pc_status__pc_st__59063A47]  DEFAULT ('background:#000;color:#fff;') FOR [pc_status_card_style_header]
GO
ALTER TABLE [dbo].[pc_status] ADD  CONSTRAINT [DF__pc_status__pc_st__59FA5E80]  DEFAULT ('background:#000;color:#fff;') FOR [pc_status_card_style_ribbon]
GO
ALTER TABLE [dbo].[pc_status] ADD  CONSTRAINT [DF__pc_status__pc_st__5AEE82B9]  DEFAULT ('SEM NOME') FOR [pc_status_card_nome_ribbon]
GO
