// Supabase Edge Function: emails you whenever someone sends the contact form.
// Secrets needed: RESEND_API_KEY, NOTIFY_EMAIL, WEBHOOK_SECRET

const esc = (s: string) =>
  s.replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]!));

Deno.serve(async (req) => {
  // Only your database webhook knows this secret, so strangers can't trigger emails.
  if (req.headers.get("x-webhook-secret") !== Deno.env.get("WEBHOOK_SECRET")) {
    return new Response("Unauthorized", { status: 401 });
  }

  const { record } = await req.json();
  if (!record) return new Response("No record", { status: 400 });

  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${Deno.env.get("RESEND_API_KEY")}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      from: "Portfolio <onboarding@resend.dev>",
      to: [Deno.env.get("NOTIFY_EMAIL")],
      reply_to: record.email,
      subject: `New portfolio message from ${String(record.name).replace(/[\r\n]/g, " ")}`,
      html: `<p><b>${esc(record.name)}</b> (${esc(record.email)})</p><p>${esc(record.message).replace(/\n/g, "<br>")}</p>`,
    }),
  });

  return new Response(res.ok ? "sent" : await res.text(), { status: res.ok ? 200 : 502 });
});
