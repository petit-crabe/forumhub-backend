-- topic
CREATE POLICY "topic_delete_author_only"
ON public."Topic"
AS PERMISSIVE
FOR DELETE
TO authenticated
USING (auth.uid() = author_id);

CREATE POLICY "topic_insert_authenticated"
ON public."Topic"
AS PERMISSIVE
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = author_id);

CREATE POLICY "topic_select_authenticated_publish"
ON public."Topic"
AS PERMISSIVE
FOR SELECT
TO authenticated
USING (((is_published = true) OR (auth.uid() = author_id)));

CREATE POLICY "topic_update_author_only"
ON public."Topic"
AS PERMISSIVE
FOR UPDATE
TO authenticated
USING (auth.uid() = author_id)
WITH CHECK (auth.uid() = author_id);


-- comment
CREATE POLICY "comment_delete_author_only"
ON public."Comment"
AS PERMISSIVE
FOR DELETE
TO authenticated
USING (auth.uid() = author_id);

CREATE POLICY "comment_insert_authenticated"
ON public."Comment"
AS PERMISSIVE
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = author_id);

CREATE POLICY "comment_select_follows_topic"
ON public."Comment"
AS PERMISSIVE
FOR SELECT
TO authenticated
USING (
  (EXISTS (
    SELECT 1
    FROM "Topic"
    WHERE (("Topic".id = "Comment".topic_id) AND ("Topic".is_published = true))
  ))
);

CREATE POLICY "comment_update_author_only"
ON public."Comment"
AS PERMISSIVE
FOR UPDATE
TO authenticated
USING (auth.uid() = author_id)
WITH CHECK (auth.uid() = author_id);
