-- Fonction : set_topic_author
CREATE OR REPLACE FUNCTION public.set_topic_author()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  NEW.author_id := auth.uid();
  RETURN NEW;
END;
$$;

-- Fonction : set_comment_author
CREATE OR REPLACE FUNCTION public.set_comment_author()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  NEW.author_id := auth.uid();
  RETURN NEW;
END;
$$;

-- Trigger : Topic
CREATE TRIGGER trigger_set_topic_author
  BEFORE INSERT ON public."Topic"
  FOR EACH ROW EXECUTE FUNCTION set_topic_author();

-- Trigger : Comment
CREATE TRIGGER trigger_set_comment_author
  BEFORE INSERT ON public."Comment"
  FOR EACH ROW EXECUTE FUNCTION set_comment_author();
  