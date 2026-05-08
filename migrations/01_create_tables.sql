-- Table: public.Topic
CREATE TABLE IF NOT EXISTS public."Topic" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "title" varchar NOT NULL,
  "content" text NOT NULL,
  "author_id" uuid NOT NULL,
  "is_published" boolean NOT NULL DEFAULT false,
  CONSTRAINT "Topic_author_id_fkey"
    FOREIGN KEY ("author_id")
    REFERENCES auth.users ("id")
);

-- Table: public.Comment
CREATE TABLE IF NOT EXISTS public."Comment" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "content" text NOT NULL,
  "author_id" uuid NOT NULL,
  "topic_id" uuid NOT NULL,
  CONSTRAINT "Comment_author_id_fkey"
    FOREIGN KEY ("author_id")
    REFERENCES auth.users ("id"),
  CONSTRAINT "Comment_topic_id_fkey"
    FOREIGN KEY ("topic_id")
    REFERENCES public."Topic" ("id")
);
