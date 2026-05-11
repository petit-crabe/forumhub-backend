ALTER TABLE public."Topic"
  ADD COLUMN "deleted_at" timestamptz DEFAULT NULL;

ALTER TABLE public."Comment"
  ADD COLUMN "deleted_at" timestamptz DEFAULT NULL;

-- Topic SELECT
DROP POLICY "topic_select_authenticated_publish" ON public."Topic";

CREATE POLICY "topic_select_authenticated_publish"
ON public."Topic"
AS PERMISSIVE
FOR SELECT
TO authenticated
USING (
  (deleted_at IS NULL AND is_published = true)
  OR (auth.uid() = author_id)
);

-- Comment SELECT
DROP POLICY "comment_select_follows_topic" ON public."Comment";

CREATE POLICY "comment_select_follows_topic"
ON public."Comment"
AS PERMISSIVE
FOR SELECT
TO authenticated
USING (
  (
    deleted_at IS NULL
    AND EXISTS (
      SELECT 1 FROM public."Topic"
      WHERE "Topic".id = "Comment".topic_id
      AND "Topic".is_published = true
      AND "Topic".deleted_at IS NULL
    )
  )
  OR (auth.uid() = author_id)
);

-- Topic soft delete
DROP POLICY "topic_delete_author_only" ON public."Topic";

CREATE POLICY "topic_soft_delete_author_only"
ON public."Topic"
AS PERMISSIVE
FOR UPDATE
TO authenticated
USING (auth.uid() = author_id)
WITH CHECK (auth.uid() = author_id);

-- Comment soft delete
DROP POLICY "comment_delete_author_only" ON public."Comment";

CREATE POLICY "comment_soft_delete_author_only"
ON public."Comment"
AS PERMISSIVE
FOR UPDATE
TO authenticated
USING (auth.uid() = author_id)
WITH CHECK (auth.uid() = author_id);
